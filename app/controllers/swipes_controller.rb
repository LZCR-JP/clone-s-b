class SwipesController < ApplicationController
  before_action :set_participant
  before_action :ensure_open

  def index
    selector = VibeCardSelector.new(@nomikai)
    selector.call
    @show_card_fallback_notice = selector.fallback?

    @cards = @nomikai.nomikai_vibe_cards.order(:position)
    @total_cards = @cards.count
    @completed_count = @participant.swipes.count

    return render plain: "No matching vibe cards available." if @total_cards.zero?

    @current_card = @cards.where.not(
      id: @participant.swipes.select(:nomikai_vibe_card_id)
    ).first

    return unless @current_card.nil?

    @participant.update!(
      completed_at: @participant.completed_at || Time.current
    )
  end

  def create
    SwipeProcessor.new(
      participant: @participant,
      nomikai: @nomikai,
      card_id: params[:nomikai_vibe_card_id],
      liked: params[:liked]
    ).call

    redirect_to participant_swipes_path(@participant.token),
                status: :see_other
  rescue SwipeProcessor::InvalidChoice
    head :unprocessable_entity
  rescue SwipeProcessor::ClosedNomikai
    render plain: "This nomikai is closed.",
           status: :forbidden
  end

  private

  def set_participant
    @participant = Participant.find_by!(
      token: params[:participant_token]
    )

    @nomikai = @participant.nomikai
  end

  def ensure_open
    return unless @nomikai.status != "open"

    render plain: "This nomikai is closed.",
           status: :forbidden
  end
end
