class Nomikai < ApplicationRecord
  STATUSES = ["open", "closed"].freeze

  belongs_to :user
  has_many :participants, dependent: :destroy
  has_many :candidates, dependent: :destroy
  has_many :nomikai_vibe_cards, dependent: :destroy
  has_many :vibe_cards, through: :nomikai_vibe_cards
  has_many :venues, through: :candidates

  has_secure_token :share_token

  before_validation :set_default_name, on: :create

  validates :area, :event_date, presence: true
  validates :group_size, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 50 }
  validates :budget_per_person, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_nil: true
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_nil: true
  validates :status, inclusion: { in: STATUSES }

  private

  def set_default_name
    return unless name.blank? && event_date.present?

    self.name = "Gathering - #{event_date.strftime('%b %d')}"
  end
end
