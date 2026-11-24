class Nomikai < ApplicationRecord
  belongs_to :user
  has_many :participants, dependent: :destroy
  has_many :candidates, dependent: :destroy
  has_many :nomikai_vibe_cards, dependent: :destroy
  has_many :vibe_cards, through: :nomikai_vibe_cards
  has_many :venues, through: :candidates

  has_secure_token :share_token

  validates :name, :area, :event_date, presence: true
  validates :group_size, numericality: { only_integer: true, greater_than: 0 }
  validates :budget_per_person, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
end
