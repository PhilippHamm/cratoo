require 'capybara'
require 'nokogiri'
require 'open-uri'
require 'capybara/dsl'
include Capybara::DSL
require 'csv'
require 'fuzzystringmatch'
require "pry-byebug"
require 'webdrivers'

class DataController < ApplicationController
  def index
    @scraped_data = Datum.all
  end

  def new
    @scrape_data = Datum.new
  end

  def create
    @scrape_data = Datum.new(datum_params)
    scrape(@scrape_data.genre, @scrape_data.quantity)
    flash.alert = 'Scrape job succesfully executed'
    @scrape_data.save
  end

  def save
    datum = Datum.find(params[:id])
    csv_options = { col_sep: ',', headers: :first_row }
    filepath    = Rails.root.join('lib', 'data', datum.filepath)
    CSV.foreach(filepath, csv_options) do |row|
      # artist
      if row['artist_1'].nil?
        artist_name = row['artist_0']
      else
        artist_name = "#{row['artist_0']}, #{row['artist_1']}"
      end
      unless Artist.find_by(name: artist_name)
        artist = Artist.new(name: artist_name)
        artist.save
      end
      # album
      album_title = row['album_title']
      unless Album.find_by(name: album_title)
        album = Album.new(name: album_title)
        album.save
      end
      # genre
      # Only first genre is saved Database design has to be different
      # Many to many relationship for each song and style and genre
      genre_name = row['genre_0']
      unless Genre.find_by(name: genre_name)
        genre = Genre.new(name: genre_name)
        genre.save
      end
      # style
      # Only first style is saved
      style_name = row['style_0']
      unless Style.find_by(name: style_name)
        style = Style.new(name: style_name, genre_id: Genre.find_by(name: genre_name).id)
        style.save
      end
      # publishing country
      publishing_country_name = row['publishing_country']
      unless PublishingCountry.find_by(name: publishing_country_name)
        publishing_country = PublishingCountry.new(name: publishing_country_name)
        publishing_country.save
      end
      # publishing_year
      if row['publishing_year'].split.size == 3
        publishing_year = Date.strptime(row['publishing_year'], '%d %b %Y')
      elsif row['publishing_year'].split.size == 2
        publishing_year = Date.strptime(row['publishing_year'], '%b %Y')
      else
        publishing_year = Date.strptime(row['publishing_year'], '%Y')
      end
      # song
      # duration is missing
      unless Song.find_by(title: row['title'])
        song = Song.new(artist_id: Artist.find_by(name: artist_name).id,
                        publishing_country_id: PublishingCountry.find_by(name: publishing_country_name).id,
                        genre_id: Genre.find_by(name: genre_name).id,
                        title: row['title'],
                        duration: row['duration'],
                        publishing_year: publishing_year,
                        score: row['score'],
                        audio_source: "http://www.youtube.com/embed/#{row['audio_source'].match(/[^=]*$/)}?autoplay=1",
                        style_id: Style.find_by(name: style_name).id,
                        album_id: Album.find_by(name: album_title).id
                        )
        song.save
      end
    end
  end
  private

  def datum_params
    params.require(:datum).permit(:genre, :quantity)
  end

  def scrape(genre, quantity)
    csv_options = { col_sep: ',' }
    filepath    = Rails.root.join('lib', 'data', "#{genre}_#{Time.now.strftime('%Y-%m-%d-%H-%M')}_#{quantity}.csv")
    @scrape_data.filepath = "#{genre}_#{Time.now.strftime('%Y-%m-%d-%H-%M')}_#{quantity}.csv"
    CSV.open(filepath, 'wb', csv_options) do |csv|
      csv << [
        'artist_0',
        'artist_1',
        'genre_0',
        'genre_1',
        'style_0',
        'style_1',
        'style_2',
        'style_3',
        'album_title',
        'title',
        'duration',
        'publishing_year',
        'publishing_country',
        'score',
        'audio_source'
      ]
    end
    #Setting capybara driver
    # Capybara.default_driver = :selenium_chrome # :selenium_chrome and :selenium_chrome_headless are also registered
    # Capybara.run_server = false

    # Capybara.default_max_wait_time = 3
    # Capybara.raise_server_errors = false

    Capybara.register_driver :chrome do |app|
      Capybara::Selenium::Driver.new(app, browser: :chrome)
    end

    Capybara.register_driver :headless_chrome do |app|
      capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
        chromeOptions: {
          args: %w[headless enable-features=NetworkService,NetworkServiceInProcess]
        }
      )

      Capybara::Selenium::Driver.new app,
        browser: :chrome,
        desired_capabilities: capabilities
    end

    Capybara.default_driver = :headless_chrome
    Capybara.javascript_driver = :headless_chrome
    Capybara.app_host = 'https://discogs.com'

    # Ghetto House
    visit('https://www.discogs.com/de/search/?sort=want%2Cdesc&style_exact=Ghetto+House&ev=gs_mc&type=release')
    # 90ies Hip Hop G-funk
    # visit('https://www.discogs.com/search/?sort=have%2Cdesc&type=all&genre_exact=Hip+Hop&decade=1990&style_exact=Gangsta&page=1')

    # 90ies Hip Hop Hardcore
    # visit('https://www.discogs.com/search/?sort=have%2Cdesc&type=all&genre_exact=Hip+Hop&decade=1990&page=4&style_exact=Hardcore+Hip-Hop')

    sleep(2)
    songs = []
    pages = 1
    jarow = FuzzyStringMatch::JaroWinkler.create(:native)
    until pages == quantity
      index_page = current_url
      puts index_page
      songs = []
      q = []
      q = all("#search_results > .card.card_large.float_fix.shortcut_navigable > h4 > a").map { |a| a['href'] }
      puts "#{q.length}"
      q.each do |release|
        song = Hash.new
        visit(release)
        if has_css?('#tracklist > div > table > tbody > tr:nth-child(2) > td.tracklist_track_pos', visible: false)
          artists = all('#profile_title > span:nth-child(1) > span > a').map { |a| a.text }
          artist_i = 0
          until artist_i == artists.length || artist_i == 2
            song["artist_#{artist_i}"] = artists[artist_i]
            artist_i += 1
          end
          genres = all('#page_content > div.body > div.profile > div:nth-child(11) > a').map{ |a| a.text}
          genre_i = 0
          until genre_i == genres.length || genre_i == 2
            song["genre_#{genre_i}"] = genres[genre_i]
            genre_i += 1
          end
          styles = all('#page_content > div.body > div.profile > div:nth-child(13) > a').map { |a| a.text }
          style_i = 0
          until style_i == styles.length || style_i == 4
            song["style_#{style_i}"] = styles[style_i]
            style_i += 1
          end
          begin
            song[:publishing_year] = find('#page_content > div.body > div.profile > div:nth-child(9) > a').text
            song[:publishing_country] = find('#page_content > div.body > div.profile > div:nth-child(7) > a').text
            song[:score] = find('#statistics > div > ul:nth-child(1) > li:nth-child(3) > span').text
            song[:quantity_score] = find('#statistics > div > ul:nth-child(1) > li:nth-child(4) > a > span').text
            song[:quantity_search] = find('#statistics > div.section_content.toggle_section_content > ul > li:nth-child(2) > a').text
            song[:album_title] = find('#profile_title > span:nth-child(2)').text
          rescue Capybara::ElementNotFound
            next
          end
          # Get all song titles from list
          song_titles = all('#tracklist > div > table > tbody > tr.tracklist_track.track > td.track.tracklist_track_title > span').map { |span| span.text}
          title_first_word = song_titles.map{|title| title.split(" ").first}
          # Get all youtube video links from player
          if has_css?('#youtube_player_placeholder')
            sources = find('#youtube_player_placeholder')["data-video-ids"].split(",")
            # Get all youtube video title from player
            youtube_titles = all('#youtube_tracklist > .youtube_track.youtube_track_paused > strong').map { |track| track.text }
            # Set index for iteration
            tracklist_i = 0

            # Iterate over song_titles,
            until tracklist_i == song_titles.length
              # Compare to all youtube video title
              youtube_tracklist_i = 0
              youtube_titles.each do |youtube_title|
                if youtube_title.downcase.match?(title_first_word[tracklist_i].gsub("(","").downcase[0..4])
                  youtube_title_words = youtube_title.downcase.split(" ")
                  title_words = song_titles[tracklist_i].downcase.split(" ")
                  match_youtube_title = youtube_title_words.select { |word| title_words.include?(word) }.join(" ")
                  if jarow.getDistance(song_titles[tracklist_i].downcase, match_youtube_title) > 0.9
                    song[:title] = song_titles[tracklist_i]
                    # assign song source if string is similar to one out of youtube video title
                    song[:audio_source] = "https://www.youtube.com/watch?v=#{sources[youtube_tracklist_i]}"
                    songs.push(song)
                    puts "#{song["artist_0"]} - #{song[:title]} - #{song[:audio_source]}, total quantity #{songs.length}"
                    if tracklist_i < song_titles.length
                      song = Hash.new
                      song['artist_0'] = songs.last['artist_0']
                      song['artist_1'] = songs.last['artist_1'] if songs.last['artist_1']
                      song['genre_0'] = songs.last['genre_0']
                      song['genre_1'] = songs.last['genre_1'] if songs.last['genre_1']
                      song['style_0'] = songs.last['style_0']
                      song['style_1'] = songs.last['style_1'] if songs.last['style_1']
                      song['style_2'] = songs.last['style_2'] if songs.last['style_2']
                      song['style_3'] = songs.last['style_3'] if songs.last['style_3']
                      song[:publishing_year] = songs.last[:publishing_year]
                      song[:publishing_country] = songs.last[:publishing_country]
                      song[:score] = songs.last[:score]
                      song[:album_title] = songs.last[:album_title]
                      break
                    end
                  end
                end
                youtube_tracklist_i += 1
              end
              tracklist_i += 1
            end
          end
        end
      end
      CSV.open(filepath, 'a', csv_options) do |csv|
        songs.each do |song|
          csv << [
            song['artist_0'],
            song['artist_1'],
            song['genre_0'],
            song['genre_1'],
            song['style_0'],
            song['style_1'],
            song['style_2'],
            song['style_3'],
            song[:album_title],
            song[:title],
            song[:duration],
            song[:publishing_year],
            song[:publishing_country],
            song[:score],
            song[:audio_source]
          ]
        end
      end
      visit(index_page)
      pages += 1
      puts "continue with page #{pages}"
      sleep(2)
      find('#pjax_container > div.pagination.bottom > form > div.responsive_wrap > ul > li:nth-child(2) > a').click
      sleep(2)
    end
  end
end
