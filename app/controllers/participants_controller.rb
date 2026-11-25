class ParticipantsController < ApplicationController
  # Code URLs are guessable in principle, so throttle lookups the same way /join does.
  rate_limit to: 10, within: 1.minute, only: :new, if: -> { params[:code].present? },
             with: -> { redirect_to join_code_path, alert: "Too many attempts. Please wait a minute and try again." }

  before_action :set_entry_point, only: %i[new create]
  before_action :ensure_open, only: %i[new create]

  def new
    @participant = @nomikai.participants.build
  end

  def create
    @participant = @nomikai.participants.build(participant_params)
    @participant.invitation = @invitation

    if @participant.save
      redirect_to participant_path(@participant.token)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @participant = Participant.find_by!(token: params[:token])
    @nomikai = @participant.nomikai
  end

  private

  # A teammate can arrive via a personal email invite, a join code, or the share link.
  def set_entry_point
    if params[:invite_token]
      set_from_invitation
    elsif params[:code]
      set_from_join_code
    else
      @nomikai = Nomikai.find_by!(share_token: params[:share_token])
      @join_path = join_path(@nomikai.share_token)
    end
  end

  def set_from_invitation
    @invitation = Invitation.find_by(token: params[:invite_token])

    if @invitation.nil? || @invitation.revoked?
      return render_unavailable(
        "This invite link is no longer valid. Ask your host to send a new one, or join with a code.",
        status: :not_found
      )
    end

    if @invitation.accepted? && @invitation.participant
      return redirect_to participant_path(@invitation.participant.token)
    end

    @nomikai = @invitation.nomikai
    @join_path = invite_path(@invitation.token)
  end

  def set_from_join_code
    @nomikai = Nomikai.find_by_join_code(params[:code])

    unless @nomikai
      return redirect_to join_code_path,
                         alert: "That code isn't valid anymore. Double-check it with your host."
    end

    @join_path = join_with_code_path(@nomikai.formatted_join_code)
  end

  def ensure_open
    return if @nomikai.accepting_participants?

    render_unavailable("This event is no longer accepting new teammates.", status: :forbidden)
  end

  def render_unavailable(message, status:)
    @message = message
    render :unavailable, status: status
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
