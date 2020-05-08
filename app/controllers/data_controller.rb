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
      songs = []
      q = []
      q = all('.page-centered .viewport .g-row .g-col-9 .cBox--resultList .cBox-body--resultitem .result-item').map { |a| a['href'] }
      if q.length < 1
        sleep (3)
        q = all('.page-centered .viewport .g-row .g-col-9 .cBox--resultList .cBox-body--resultitem .result-item').map { |a| a['href'] }
      end
      puts "#{q.length}"
      # Inseratdatum
      publishing_dates = all('#z1234 > div.viewport > div > div:nth-child(3) > div:nth-child(4) > div.g-col-9 > div:nth-child(3) > div.cBox-body.cBox-body--resultitem.dealerAd.rbt-reg.rbt-no-top > a > div > div.g-col-9 > div:nth-child(1) > div.g-col-8 > div > span.u-block.u-pad-top-9.rbt-onlineSince').map { |a| a.text }
      i = -1
      q.each do |ad|
        begin
          i += 1
          visit(ad)
          car = Hash.new
          car[:ad_link] = ad
          if has_css?('#rbt-envkv\.consumption-v > div.u-margin-bottom-9')
            consumptions = all('#rbt-envkv\.consumption-v > div.u-margin-bottom-9').map { |c| c.text }
            car[:consumption] = consumptions.join("\n")
          end
          s = all('#z1234 > div.viewport > div > div:nth-child(2) > div:nth-child(5) > div.g-col-8 > div.cBox.cBox--content.cBox--vehicle-details.u-overflow-inherit > div:nth-child(2) > div > div.g-col-2 > div > div > div > div > div > div > div > div.carousel-img-wrapper.u-flex-centerer.u-border.u-text-pointer.slick-slide', visible: false).length
          # !!!! sometimes doesn't find following selector if no pictrues
          find('#z1234 > div.viewport > div > div:nth-child(2) > div:nth-child(5) > div.g-col-8 > div.cBox.cBox--content.cBox--vehicle-details.u-overflow-inherit > div:nth-child(2) > div > div.g-col-2 > div > div > div > div > div > div > div > div:nth-child(2)').click
          e = 0
          # sleep(1)
          if s > 2
            until e >= (s - 2) || e > 11
              all_car_nodes = all("#rbt-gallery-img-#{e} > img", visible: false)
              car["image_#{e}"] = all_car_nodes.last['data-lazy'].insert(0, 'https:')
              e += 1
            end
          end
          find('#standard-overlay-image-gallery-container > div:nth-child(2) > div > div > span').click
          car[:title] = find('#rbt-ad-title').text
          car[:price] = find('#rbt-pt-v').text.match(/\d+.\d+\s./)
          # Define variable to save time
          if has_css?('#rbt-damageCondition-v')
            car[:damage_condition] = find('#rbt-damageCondition-v').text
          end
          if has_css?('#rbt-countryVersion-v')
            car[:country_version] = find('#rbt-countryVersion-v').text
          end
          if has_css?('#rbt-category-v')
            car[:category] = find('#rbt-category-v').text
          end
          car[:mileage] = find('#rbt-mileage-v').text
          if has_css?('#rbt-cubicCapacity-v')
            car[:cubic_capacity] = find('#rbt-cubicCapacity-v').text
          end
          car[:power] = find('#rbt-power-v').text
          car[:fuel] = find('#rbt-fuel-v').text
          if has_css?('#rbt-envkv\.emission-v')
            car[:emission] = find('#rbt-envkv\.emission-v').text
          end
          if has_css?('#rbt-numberOfPreviousOwners-v')
            car[:num_owners] = find('#rbt-numberOfPreviousOwners-v').text
          end
          if has_css?('#rbt-numSeats-v')
            car[:num_seats] = find('#rbt-numSeats-v').text
          end
          if has_css?('#rbt-doorCount-v')
            car[:door_count] = find('#rbt-doorCount-v').text
          end
          if has_css?('#rbt-transmission-v')
            car[:transmission] = find('#rbt-transmission-v').text
          end
          if has_css?('#rbt-emissionClass-v')
            car[:emission_class] = find('#rbt-emissionClass-v').text
          end
          if has_css?('#rbt-emissionsSticker-v')
            car[:emssion_sticker] = find('#rbt-emissionsSticker-v').text
          end
          if has_css?('#rbt-firstRegistration-v')
            car[:first_registration] = find('#rbt-firstRegistration-v').text
          end
          if has_css?('#rbt-hu-v')
            car[:hu] = find('#rbt-hu-v').text
          end
          if has_css?('#rbt-climatisation-v')
            car[:climatisation] = find('#rbt-climatisation-v').text
          end
          if has_css?('#rbt-constructionYear-v')
            car[:construction_year] = find('#rbt-constructionYear-v').text
          end
          if has_css?('#rbt-parkAssists-v')
            car[:park_assist] = find('#rbt-parkAssists-v').text
          end
          if has_css?('#rbt-airbag-v')
            car[:airbag] = find('#rbt-airbag-v').text
          end
          if has_css?('#rbt-manufacturerColorName-v')
            car[:manufacturer_color_name] = find('#rbt-manufacturerColorName-v').text
          end
          if has_css?('#rbt-color-v')
            car[:color] = find('#rbt-color-v').text
          end

          if has_css?('#rbt-interior-v')
            car[:interior] = find('#rbt-interior-v').text
          end
          car[:dealer_name] = find('#dealer-details-link-top > h4').text
          car[:dealer_postal_code] = find('#rbt-seller-address').text.match(/\d{5}/)
          car[:dealer_city] = find('#rbt-seller-address').text.match(/[a-zA-Z]+(-)?\D+$/)
          car[:dealer_address] = find('#rbt-seller-address').text.match(/^\D*\d*\w(-|,)?\w*/)
          car[:dealer_phone] = find('#rbt-seller-phone').text.sub('Tel.: ','')
          if has_css?('#rbt-top-dealer-info > div > div > span > a > span.star-rating-s.u-valign-middle.u-margin-right-9')
            car[:dealer_rating] = find('#rbt-top-dealer-info > div > div > span > a > span.star-rating-s.u-valign-middle.u-margin-right-9')['data-rating']
            car[:dealer_quantity_ratings] = find('#rbt-top-dealer-info > div > div > span > a > span.amount-of-ratings').text
          end
          features = all('#rbt-features > div > div.g-col-6 > div.bullet-list > p').map { |p| p.text }
          car[:features] = features.join("\n")
          car[:publishing_date] = publishing_dates[i].match(/\d{2}.\d{2}.\d{4}/)
          cars.push(car)
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
        puts "#{car[:title]}, total quantity #{cars.length}"
      end
      CSV.open(filepath, 'a', csv_options) do |csv|
        cars.each do |car|
          csv << [
            car[:ad_link],
            car[:title],
            car[:price],
            car[:damage_condition],
            car[:category],
            car[:country_version],
            car[:consumption],
            car[:mileage],
            car[:cubic_capacity],
            car[:power],
            car[:fuel],
            car[:emission],
            car[:num_owners],
            car[:num_seats],
            car[:door_count],
            car[:transmission],
            car[:emission_class],
            car[:emssion_sticker],
            car[:first_registration],
            car[:hu],
            car[:climatisation],
            car[:construction_year],
            car[:park_assist],
            car[:airbag],
            car[:manufacturer_color_name],
            car[:color],
            car[:interior],
            car["image_1"],
            car["image_2"],
            car["image_3"],
            car["image_4"],
            car["image_5"],
            car["image_6"],
            car["image_7"],
            car["image_8"],
            car["image_8"],
            car["image_10"],
            car["image_11"],
            car["image_12"],
            car[:features],
            car[:dealer_name],
            car[:dealer_postal_code],
            car[:dealer_city],
            car[:dealer_address],
            car[:dealer_phone],
            car[:dealer_rating],
            car[:dealer_quantity_ratings],
            car[:publishing_date]
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
    cars
  end
end
