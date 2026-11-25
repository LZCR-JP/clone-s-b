class SwipeProcessor
  def initialize(participant:, nomikai:, card_id:, liked:)
    @participant = participant
    @nomikai = nomikai
    @card_id = card_id
    @liked = liked
  end

  def call
    card = @nomikai.nomikai_vibe_cards.find(@card_id)

    swipe = @participant.swipes.find_or_initialize_by(
      nomikai_vibe_card: card
    )

    swipe.liked = @liked == "true"
    swipe.save!

    complete_participant_if_finished
  end

  private

  def complete_participant_if_finished
    return unless @participant.swipes.count ==
                  @nomikai.nomikai_vibe_cards.count

    @participant.update!(
      completed_at: @participant.completed_at || Time.current
    )
  end
end
