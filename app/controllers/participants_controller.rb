class ParticipantsController < ApplicationController
  before_action :set_nomikai, only: %i[new create]
  before_action :ensure_open, only: %i[new create]

  def new
    @participant = @nomikai.participants.build
  end

  def create
    @participant = @nomikai.participants.build(participant_params)

    if @participant.save
      redirect_to participant_path(@participant.token)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @participant = Participant.find_by!(token: params[:token])
    @nomikai = @participant.nomikai
    @selected_candidate = @nomikai.candidates
                                  .includes(:venue)
                                  .find_by(selected: true)

    @candidate_vote = if @selected_candidate
                        @participant.candidate_votes.find_by(
                          candidate: @selected_candidate
                        )
                      end
  end

  private

  def set_nomikai
    @nomikai = Nomikai.find_by!(share_token: params[:share_token])
  end

  def ensure_open
    return unless @nomikai.status != "open"

    render plain: "This nomikai is closed.", status: :forbidden
  end

  def participant_params
    params.require(:participant).permit(
      :nickname,
      :budget_max,
      :non_drinker,
      restrictions: []
    )
  end
end
