require 'csv'

# read csv
# csv_options = { col_sep: ',', headers: :first_row }
# filepath = Rails.root.join('lib', 'data', 'jazz.csv')
# CSV.foreach(filepath, csv_options) do |row|
#   s = Song.create!
#   s.artist = row['Artist']
#   s.genre = row['Genre']
#   s.style_id = row['Style']
#   s.title = row['Title']
#   s.duration = row['Duration']
#   s.publishing_year = row['Publishing Year']
#   s.publishing_country = row['Publishing country d']
#   s.score = row['Score']
#   s.audio_source = row['Audio_source']
# end

# puts "There are now #{Song.count} rows in the song's table"
artist1 = Artist.create!(
  name:"Flemmenup"
  )

genre1 = Genre.create!(
  name: "Electronic"
  )

style1 = Style.create!(
  name: "House",
  genre_id: 1
  )

publishing_country = PublishingCountry.create!(
  name: "UK"
  )

song1 = Song.create!(
  title: "KMFH",
  duration: "4.61",
  artist_id: 1,
  genre_id: 1,
  style_id: 1,
  publishing_year: Date.new(2013,06,24),
  publishing_country_id: 1,
  score: "4.09",
  audio_source: "https://www.youtube.com/watch?v=XG-9ygxNH2Y"
  )

song2 = Song.create!(
  title: "Delroy Edwards",
  duration: "4.61",
  artist_id: 1,
  genre_id: 1,
  style_id: 1,
  publishing_year: Date.new(2013,06,24),
  publishing_country_id: 1,
  score: "4.11",
  audio_source: "https://www.youtube.com/watch?v=XG-9ygxNH2Y"
  )

song3 = Song.create!(
  title: "D.J. Funk",
  duration: "4.61",
  artist_id: 1,
  genre_id: 1,
  style_id: 1,
  publishing_year: Date.new(2013,06,24),
  publishing_country_id: 1,
  score: "4.29",
  audio_source: "https://www.youtube.com/watch?v=XG-9ygxNH2Y"
  )

song4 = Song.create!(
  title: "D.J. Slugo",
  duration: "4.61",
  artist_id: 1,
  genre_id: 1,
  style_id: 1,
  publishing_year: Date.new(2013,06,24),
  publishing_country_id: 1,
  score: "4.41",
  audio_source: "https://www.youtube.com/watch?v=XG-9ygxNH2Y"
  )

song5 = Song.create!(
  title: "Lazare Hoche",
  duration: "4.61",
  artist_id: 1,
  genre_id: 1,
  style_id: 1,
  publishing_year: Date.new(2013,06,24),
  publishing_country_id: 1,
  score: "4.59",
  audio_source: "https://www.youtube.com/watch?v=XG-9ygxNH2Y"
  )
