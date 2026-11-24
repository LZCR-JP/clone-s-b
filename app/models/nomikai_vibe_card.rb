class NomikaiVibeCard < ApplicationRecord
  belongs_to :nomikai
  belongs_to :vibe_card
  has_many :swipes, dependent: :destroy

  validates :vibe_card_id, uniqueness: { scope: :nomikai_id }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
