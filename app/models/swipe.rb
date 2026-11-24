class Swipe < ApplicationRecord
  belongs_to :participant
  belongs_to :nomikai_vibe_card

  validates :nomikai_vibe_card_id, uniqueness: { scope: :participant_id }
  validates :liked, inclusion: { in: [true, false] }
  validate :participant_and_card_in_same_nomikai

  private

  def participant_and_card_in_same_nomikai
    return if participant.nil? || nomikai_vibe_card.nil?
    return if participant.nomikai_id == nomikai_vibe_card.nomikai_id

    errors.add(:base, "participant and vibe card must belong to the same nomikai")
  end
end
