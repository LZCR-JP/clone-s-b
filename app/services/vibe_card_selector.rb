class VibeCardSelector
  CARD_LIMIT = 15

  def initialize(nomikai)
    @nomikai = nomikai
    @fallback_used = false
  end

  def call
    @nomikai.with_lock do
      build_deck unless @nomikai.nomikai_vibe_cards.exists?
      @nomikai.nomikai_vibe_cards
    end
  end

  def fallback?
    return true if @fallback_used

    @nomikai.nomikai_vibe_cards.includes(:vibe_card).any? do |nomikai_vibe_card|
      !matches_event_limits?(nomikai_vibe_card.vibe_card)
    end
  end

  private

  def build_deck
    cards = matching_cards
    cards = fallback_cards if cards.empty?

    cards.each_with_index do |card, index|
      @nomikai.nomikai_vibe_cards.create!(vibe_card: card, position: index + 1)
    end
  end

  def fallback_cards
    @fallback_used = true
    random_cards(photo_cards)
  end

  def photo_cards
    VibeCard.where(active: true)
            .where.not(image_url: [nil, ""])
  end

  def matching_cards
    random_cards(filter_by_budget(filter_by_group_size(photo_cards)))
  end

  def filter_by_group_size(scope)
    size = @nomikai.group_size

    scope.where("min_group_size IS NULL OR min_group_size <= ?", size)
         .where("max_group_size IS NULL OR max_group_size >= ?", size)
  end

  def filter_by_budget(scope)
    budget = @nomikai.budget_per_person
    return scope if budget.nil?

    scope.where("min_budget IS NULL OR min_budget <= ?", budget)
         .where("max_budget IS NULL OR max_budget >= ?", budget)
  end

  def random_cards(scope)
    scope.order(Arel.sql("RANDOM()")).limit(CARD_LIMIT)
  end

  def matches_event_limits?(card)
    within_range?(card.min_budget, card.max_budget, @nomikai.budget_per_person) &&
      within_range?(card.min_group_size, card.max_group_size, @nomikai.group_size)
  end

  def within_range?(min, max, value)
    return true if value.nil?

    (min.nil? || min <= value) && (max.nil? || max >= value)
  end
end
