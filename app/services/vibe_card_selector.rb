class VibeCardSelector
  CARD_LIMIT = 15

  def initialize(nomikai)
    @nomikai = nomikai
  end

  def call
    @nomikai.with_lock do
      unless @nomikai.nomikai_vibe_cards.exists?
        matching_cards.each_with_index do |card, index|
          @nomikai.nomikai_vibe_cards.create!(
            vibe_card: card,
            position: index + 1
          )
        end
      end

      @nomikai.nomikai_vibe_cards
    end
  end

  private

  def matching_cards
    budget = @nomikai.budget_per_person
    group_size = @nomikai.group_size

    VibeCard.where(active: true)
            .where("min_budget IS NULL OR min_budget <= ?", budget)
            .where("max_budget IS NULL OR max_budget >= ?", budget)
            .where("min_group_size IS NULL OR min_group_size <= ?", group_size)
            .where("max_group_size IS NULL OR max_group_size >= ?", group_size)
            .order(Arel.sql("RANDOM()"))
            .limit(CARD_LIMIT)
  end
end
