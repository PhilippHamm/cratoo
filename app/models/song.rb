class Song < ApplicationRecord
  belongs_to :artist
  belongs_to :publishing_country
  belongs_to :genre
  belongs_to :style
  belongs_to :album
end
