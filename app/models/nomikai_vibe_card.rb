class NomikaiVibeCard < ApplicationRecord
  belongs_to :nomikai
  belongs_to :vibe_card
  has_many :swipes
end
