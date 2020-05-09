require 'capybara'
require 'nokogiri'
require 'open-uri'
require 'capybara/dsl'
include Capybara::DSL
require 'csv'

class DataController < ApplicationController
  def new
    @scrape_data = Datum.new
  end

  def create
    @scrape_data = Datum.new(datum_params)
    if @scrape_data.save
      scrape(@scrape_data.genre, @scrape_data.quantity)
    else
      new_datum_path
    end
  end

  private

  def datum_params
    params.require(:datum).permit(:genre, :quantity)
  end

  def scrape(genre, quantity)
    csv_options = { col_sep: ',' }
    filepath    = Rails.root.join('lib', 'data', 'ghetto_house.csv')
    CSV.open(filepath, 'wb', csv_options) do |csv|
      csv << [
        'artist',
        'title',
        'duration',
        'genre',
        'style',
        'publishing_year',
        'publishing_country',
        'score',
        'audio_source_1',
        'audio_source_2',
        'audio_source_3',
        'audio_source_4',
        'audio_source_5',
        'audio_source_6',
        'audio_source_7',
        'audio_source_8',
        'audio_source_9',
        'audio_source_10',
        'audio_source_11',
        'audio_source_12',
        'audio_source_13'
      ]
    end
    #Setting capybara driver
    Capybara.default_driver = :selenium_chrome # :selenium_chrome and :selenium_chrome_headless are also registered
    Capybara.run_server = false
    Capybara.app_host = 'https://discogs.com'
    Capybara.default_max_wait_time = 3
    Capybara.raise_server_errors = false


    # visit('https://www.mobile.de')
    # fill_in('ambit-search-location', with: city)
    # sleep(2)
    # find('#ambit-search-location').native.send_keys(:return)
    # sleep(1)
    # click_button("qssub")
    # sleep(2)

    # Ghetto House
    visit('https://www.discogs.com/de/search/?sort=want%2Cdesc&style_exact=Ghetto+House&ev=gs_mc')
    sleep(2)
    songs = []
    j = 2
    until j == 40
      # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      songs = []
      q = []
      q = all("#search_results > .card.card_large.float_fix.shortcut_navigable > h4 > a").map { |a| a['href'] }
      # if q.length < 1
      #   sleep (3)
      #   q = all('.page-centered .viewport .g-row .g-col-9 .cBox--resultList .cBox-body--resultitem .result-item').map { |a| a['href'] }
      # end
      puts "#{q.length}"
      # Inseratdatum
      i = -1
      q.each do |release|
        begin
          i += 1
          visit(release)
          song = Hash.new
          if has_css?('#tracklist > div > table > tbody > tr.first.tracklist_track.track > td.tracklist_track_pos')
            song[:artist] = find('#profile_title > span:nth-child(1) > span > a').text
            song[:genre] = find('#page_content > div.body > div.profile > div:nth-child(11) > a')
        'style',
        'publishing_year',
        'publishing_country',
        'score',
            song[:title] = find('#rbt-ad-title').text
          end
          song[:ad_link] = ad
          if has_css?('#rbt-envkv\.consumption-v > div.u-margin-bottom-9')
            consumptions = all('#rbt-envkv\.consumption-v > div.u-margin-bottom-9').map { |c| c.text }
            song[:consumption] = consumptions.join("\n")
          end
          s = all('#z1234 > div.viewport > div > div:nth-child(2) > div:nth-child(5) > div.g-col-8 > div.cBox.cBox--content.cBox--vehicle-details.u-overflow-inherit > div:nth-child(2) > div > div.g-col-2 > div > div > div > div > div > div > div > div.songousel-img-wrapper.u-flex-centerer.u-border.u-text-pointer.slick-slide', visible: false).length
          # !!!! sometimes doesn't find following selector if no pictrues
          find('#z1234 > div.viewport > div > div:nth-child(2) > div:nth-child(5) > div.g-col-8 > div.cBox.cBox--content.cBox--vehicle-details.u-overflow-inherit > div:nth-child(2) > div > div.g-col-2 > div > div > div > div > div > div > div > div:nth-child(2)').click
          e = 0
          # sleep(1)
          if s > 2
            until e >= (s - 2) || e > 11
              all_song_nodes = all("#rbt-gallery-img-#{e} > img", visible: false)
              song["image_#{e}"] = all_song_nodes.last['data-lazy'].insert(0, 'https:')
              e += 1
            end
          end
          find('#standard-overlay-image-gallery-container > div:nth-child(2) > div > div > span').click
          song[:title] = find('#rbt-ad-title').text
          song[:price] = find('#rbt-pt-v').text.match(/\d+.\d+\s./)
          # Define variable to save time
          if has_css?('#rbt-damageCondition-v')
            song[:damage_condition] = find('#rbt-damageCondition-v').text
          end
          if has_css?('#rbt-countryVersion-v')
            song[:country_version] = find('#rbt-countryVersion-v').text
          end
          if has_css?('#rbt-category-v')
            song[:category] = find('#rbt-category-v').text
          end
          song[:mileage] = find('#rbt-mileage-v').text
          if has_css?('#rbt-cubicCapacity-v')
            song[:cubic_capacity] = find('#rbt-cubicCapacity-v').text
          end
          song[:power] = find('#rbt-power-v').text
          song[:fuel] = find('#rbt-fuel-v').text
          if has_css?('#rbt-envkv\.emission-v')
            song[:emission] = find('#rbt-envkv\.emission-v').text
          end
          if has_css?('#rbt-numberOfPreviousOwners-v')
            song[:num_owners] = find('#rbt-numberOfPreviousOwners-v').text
          end
          if has_css?('#rbt-numSeats-v')
            song[:num_seats] = find('#rbt-numSeats-v').text
          end
          if has_css?('#rbt-doorCount-v')
            song[:door_count] = find('#rbt-doorCount-v').text
          end
          if has_css?('#rbt-transmission-v')
            song[:transmission] = find('#rbt-transmission-v').text
          end
          if has_css?('#rbt-emissionClass-v')
            song[:emission_class] = find('#rbt-emissionClass-v').text
          end
          if has_css?('#rbt-emissionsSticker-v')
            song[:emssion_sticker] = find('#rbt-emissionsSticker-v').text
          end
          if has_css?('#rbt-firstRegistration-v')
            song[:first_registration] = find('#rbt-firstRegistration-v').text
          end
          if has_css?('#rbt-hu-v')
            song[:hu] = find('#rbt-hu-v').text
          end
          if has_css?('#rbt-climatisation-v')
            song[:climatisation] = find('#rbt-climatisation-v').text
          end
          if has_css?('#rbt-constructionYear-v')
            song[:construction_year] = find('#rbt-constructionYear-v').text
          end
          if has_css?('#rbt-parkAssists-v')
            song[:park_assist] = find('#rbt-parkAssists-v').text
          end
          if has_css?('#rbt-airbag-v')
            song[:airbag] = find('#rbt-airbag-v').text
          end
          if has_css?('#rbt-manufacturerColorName-v')
            song[:manufacturer_color_name] = find('#rbt-manufacturerColorName-v').text
          end
          if has_css?('#rbt-color-v')
            song[:color] = find('#rbt-color-v').text
          end

          if has_css?('#rbt-interior-v')
            song[:interior] = find('#rbt-interior-v').text
          end
          song[:dealer_name] = find('#dealer-details-link-top > h4').text
          song[:dealer_postal_code] = find('#rbt-seller-address').text.match(/\d{5}/)
          song[:dealer_city] = find('#rbt-seller-address').text.match(/[a-zA-Z]+(-)?\D+$/)
          song[:dealer_address] = find('#rbt-seller-address').text.match(/^\D*\d*\w(-|,)?\w*/)
          song[:dealer_phone] = find('#rbt-seller-phone').text.sub('Tel.: ','')
          if has_css?('#rbt-top-dealer-info > div > div > span > a > span.star-rating-s.u-valign-middle.u-margin-right-9')
            song[:dealer_rating] = find('#rbt-top-dealer-info > div > div > span > a > span.star-rating-s.u-valign-middle.u-margin-right-9')['data-rating']
            song[:dealer_quantity_ratings] = find('#rbt-top-dealer-info > div > div > span > a > span.amount-of-ratings').text
          end
          features = all('#rbt-features > div > div.g-col-6 > div.bullet-list > p').map { |p| p.text }
          song[:features] = features.join("\n")
          song[:publishing_date] = publishing_dates[i].match(/\d{2}.\d{2}.\d{4}/)
          songs.push(song)
        rescue Capybara::ElementNotFound
          sleep(2)
          next
        rescue Selenium::WebDriver::Error::ElementClickInterceptedError
          sleep(2)
          next
        rescue => e
          sleep(2)
          next
        end
        puts "#{song[:title]}, total quantity #{songs.length}"
      end
      CSV.open(filepath, 'a', csv_options) do |csv|
        songs.each do |song|
          csv << [
            song[:ad_link],
            song[:title],
            song[:price],
            song[:damage_condition],
            song[:category],
            song[:country_version],
            song[:consumption],
            song[:mileage],
            song[:cubic_capacity],
            song[:power],
            song[:fuel],
            song[:emission],
            song[:num_owners],
            song[:num_seats],
            song[:door_count],
            song[:transmission],
            song[:emission_class],
            song[:emssion_sticker],
            song[:first_registration],
            song[:hu],
            song[:climatisation],
            song[:construction_year],
            song[:park_assist],
            song[:airbag],
            song[:manufacturer_color_name],
            song[:color],
            song[:interior],
            song["image_1"],
            song["image_2"],
            song["image_3"],
            song["image_4"],
            song["image_5"],
            song["image_6"],
            song["image_7"],
            song["image_8"],
            song["image_8"],
            song["image_10"],
            song["image_11"],
            song["image_12"],
            song[:features],
            song[:dealer_name],
            song[:dealer_postal_code],
            song[:dealer_city],
            song[:dealer_address],
            song[:dealer_phone],
            song[:dealer_rating],
            song[:dealer_quantity_ratings],
            song[:publishing_date]
          ]
        end
      end
      begin
        find('#srp-back-link', visible: false).hover
        find('#srp-back-link').click
      rescue Capybara::ElementNotFound
        puts "ElementNotFound"
        execute_script "window.scrollBy(0,5000)"
        sleep(2)
        execute_script "window.scrollBy(0,-5000)"
        sleep(3)
        find('#srp-back-link', visible: false).hover
        find('#srp-back-link', visible: false).click if has_css?('#srp-back-link')
        puts "rescued"
      rescue Selenium::WebDriver::Error::ElementClickInterceptedError
        puts "ElementClickInterceptedError 1"
        execute_script "window.scrollBy(0,5000)"
        sleep(2)
        execute_script "window.scrollBy(0,-5000)"
        sleep(3)
        find('#srp-back-link', visible: false).hover
        find('#srp-back-link', visible: false).click if has_css?('#srp-back-link')
        puts "rescued"
      end
      sleep(2)
      execute_script "window.scrollBy(0,5000)"
      sleep(1)
      execute_script "window.scrollBy(0,5000)"
      find("#rbt-p-#{j}", visible: false).hover
      find("#rbt-p-#{j}", visible: false).click
      sleep(1)
      begin
        while find('#z1234 > div.viewport > div > div:nth-child(3) > div:nth-child(4) > div.g-col-9 > div:nth-child(3) > div.cBox-body.u-text-center.u-margin-top-18 > ul.pagination > li > span.btn.btn--muted.btn--s.disabled').text.to_i < j
          puts "next site not ready... scroll action 2 sec wait"
          sleep(2)
          execute_script "window.scrollBy(0,-5000)"
          sleep(2)
          execute_script "window.scrollBy(0,4500)"
          find("#rbt-p-#{j}", visible: false).hover
          find("#rbt-p-#{j}", visible: false).click
        end
      rescue Selenium::WebDriver::Error::ElementClickInterceptedError
        puts "ElementClickInterceptedError 2"
        execute_script "window.scrollBy(0,5000)"
        sleep(2)
        execute_script "window.scrollBy(0,-5000)"
        sleep(2)
        find("#rbt-p-#{j}", visible: false).hover
        find("#rbt-p-#{j}", visible: false).click
        puts "rescued"
      end
      puts "continue with page #{j}"
      j += 1
    end
    songs
  end
end
