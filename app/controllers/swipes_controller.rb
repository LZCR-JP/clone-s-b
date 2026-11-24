class SwipesController < ApplicationController
  before_action :set_participant
  before_action :ensure_open

  def index
    VibeCardSelector.new(@nomikai).call

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
    @nomikai.with_lock do
      if @nomikai.status != "open"
        return render plain: "This nomikai is closed.",
                      status: :forbidden
      end

      card = @nomikai.nomikai_vibe_cards.find(
        params[:nomikai_vibe_card_id]
      )

      return head :unprocessable_entity unless ["true", "false"].include?(params[:liked].to_s)

      swipe = @participant.swipes.find_or_initialize_by(
        nomikai_vibe_card: card
      )

      swipe.liked = params[:liked] == "true"
      swipe.save!

      if @participant.swipes.count ==
         @nomikai.nomikai_vibe_cards.count

        @participant.update!(
          completed_at: @participant.completed_at || Time.current
        )
      end
    end

    redirect_to participant_swipes_path(@participant.token),
                status: :see_other
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
