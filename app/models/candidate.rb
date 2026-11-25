class Candidate < ApplicationRecord
  belongs_to :nomikai
  belongs_to :venue
  has_many :candidate_votes, dependent: :destroy

  validates :venue_id, uniqueness: { scope: :nomikai_id }
  validates :score, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :rank, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :selected, inclusion: { in: [true, false] }
end
