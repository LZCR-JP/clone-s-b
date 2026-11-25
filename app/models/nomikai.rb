class Nomikai < ApplicationRecord
  STATUSES = ["open", "closed"].freeze

  JOIN_CODE_PREFIX = "SWIPE".freeze
  # No look-alike characters (0/O, 1/I/L) so codes are easy to read aloud and type.
  JOIN_CODE_ALPHABET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789".chars.freeze
  JOIN_CODE_LENGTH = 6

  belongs_to :user
  has_many :participants, dependent: :destroy
  has_many :invitations, dependent: :destroy
  has_many :candidates, dependent: :destroy
  has_many :nomikai_vibe_cards, dependent: :destroy
  has_many :vibe_cards, through: :nomikai_vibe_cards
  has_many :venues, through: :candidates

  has_secure_token :share_token

  before_validation :set_default_name, on: :create
  before_validation :assign_join_code, on: :create

  validates :area, :event_date, presence: true
  validates :group_size, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 50 }
  validates :budget_per_person, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_nil: true
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_nil: true
  validates :status, inclusion: { in: STATUSES }
  validates :join_code, presence: true, uniqueness: true

  # Accepts "SWIPE-K7QM2P", "swipe k7qm2p", "K7QM2P", etc.
  def self.normalize_join_code(input)
    code = input.to_s.upcase.gsub(/[^A-Z0-9]/, "")
    code = code.delete_prefix(JOIN_CODE_PREFIX) if code.length > JOIN_CODE_LENGTH
    code
  end

  def self.find_by_join_code(input)
    code = normalize_join_code(input)
    return if code.length != JOIN_CODE_LENGTH

    find_by(join_code: code)
  end

  def self.generate_join_code
    loop do
      code = Array.new(JOIN_CODE_LENGTH) { JOIN_CODE_ALPHABET.sample(random: SecureRandom) }.join
      break code unless exists?(join_code: code)
    end
  end

  def formatted_join_code
    "#{JOIN_CODE_PREFIX}-#{join_code}"
  end

  # Revokes the current code; anyone holding the old one can no longer join.
  def regenerate_join_code!
    update!(join_code: self.class.generate_join_code)
  end

  def accepting_participants?
    status == "open" && event_date.present? && event_date.future?
  end

  private

  def set_default_name
    return unless name.blank? && event_date.present?

    self.name = "Gathering - #{event_date.strftime('%b %d')}"
  end

  def assign_join_code
    self.join_code ||= self.class.generate_join_code
  end
end
