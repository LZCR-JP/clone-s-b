class CandidateVote < ApplicationRecord
  belongs_to :participant
  belongs_to :candidate

  validates :candidate_id, uniqueness: { scope: :participant_id }
  validates :approved, inclusion: { in: [true, false] }

  validate :participant_and_candidate_belong_to_same_nomikai

  private

  def participant_and_candidate_belong_to_same_nomikai
    return if participant.nil? || candidate.nil?
    return if participant.nomikai_id == candidate.nomikai_id

    errors.add(:candidate, "must belong to the participant's event")
  end
end
