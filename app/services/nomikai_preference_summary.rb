class NomikaiPreferenceSummary
  def initialize(nomikai)
    @nomikai = nomikai
  end

  def call
    participants = @nomikai.participants.to_a
    cards_with_swipes = @nomikai.nomikai_vibe_cards
                                .joins(:swipes, :vibe_card)

    {
      area: @nomikai.area,
      event_budget_per_person: @nomikai.budget_per_person,
      group_size: @nomikai.group_size,
      participants_joined: participants.size,
      participants_completed: participants.count { |p| p.completed_at.present? },
      participant_budget_maxima: participants.filter_map(&:budget_max),
      non_drinkers: participants.count(&:non_drinker?),
      dietary_restrictions: participants
                            .flat_map(&:restrictions)
                            .compact
                            .reject(&:blank?)
                            .tally,
      liked_vibes: cards_with_swipes
                   .where(swipes: { liked: true })
                   .group("vibe_cards.title")
                   .count,
      disliked_vibes: cards_with_swipes
                      .where(swipes: { liked: false })
                      .group("vibe_cards.title")
                      .count
    }
  end
end
