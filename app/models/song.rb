class Song < ApplicationRecord
  belongs_to :artist
  belongs_to :publishing_country
  belongs_to :genre
  belongs_to :style, through: :genre
end
