class Venue < ApplicationRecord
  has_many :candidates, dependent: :destroy

  validates :google_place_id, presence: true, uniqueness: true
end
