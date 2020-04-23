class Genre < ApplicationRecord
  validates :name, presence: true
  validates_inclusion_of :name, in: ['Blue', 'Brass & Military', 'Children’s', 'Classical', 'Electronic', 'Folk, World & Country', 'Funk/Soul', 'Hip Hop', 'Jazz', 'Latin', 'Non-Music', 'Pop', 'Reggae', 'Rock', 'Stage & Screen']
end
