class Participant < ApplicationRecord
  belongs_to :nomikai
  has_many :swipes, dependent: :destroy

  has_secure_token :token

  validates :nickname, presence: true, length: { maximum: 30 }
  validates :budget_max, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :non_drinker, inclusion: { in: [true, false] }
end
