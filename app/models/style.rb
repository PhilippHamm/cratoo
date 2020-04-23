class Style < ApplicationRecord
  belongs_to :genre
  validates :name, presence: true
  # inclusion as well
end
