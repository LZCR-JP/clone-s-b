class CandidateVotesController < ApplicationController
  before_action :set_participant
  before_action :ensure_open

  def create
    approved_value = params[:approved].to_s

    return head :unprocessable_entity unless %w[true false].include?(approved_value)

    candidate = @nomikai.candidates.find_by!(
      id: params[:candidate_id],
      selected: true
    )

    vote = @participant.candidate_votes.find_or_initialize_by(
      candidate: candidate
    )
    vote.update!(approved: approved_value == "true")

    notice =
      if vote.approved?
        "You approved the selected restaurant."
      else
        "You asked for another option."
      end

    redirect_to participant_path(@participant.token),
                status: :see_other,
                notice: notice
  end

  private

  def set_participant
    @participant = Participant.find_by!(
      token: params[:participant_token]
    )
    @nomikai = @participant.nomikai
  end

  def ensure_open
    return if @nomikai.status == "open"

    render plain: "This nomikai is closed.",
           status: :forbidden
  end
end
