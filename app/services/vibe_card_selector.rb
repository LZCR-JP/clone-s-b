class VibeCardSelector
  CARD_LIMIT = 15

  TYPE_TARGETS = {
    "food" => 8,
    "venue" => 5,
    "people" => 2
  }.freeze

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

      @nomikai.nomikai_vibe_cards.order(:position)
    end
  end

  private

  def matching_cards
    available_cards = eligible_cards.to_a.shuffle

    selected_cards = []
    cuisine_counts = Hash.new(0)

    TYPE_TARGETS.each do |type, target|
      pool = available_cards.select do |card|
        card.image_type == type
      end

      target.times do
        break if pool.empty?

        card = pick_diverse_card(pool, cuisine_counts)

        selected_cards << card

        cuisine_counts[card.cuisine] += 1

        pool.delete(card)
        available_cards.delete(card)
      end
    end

    while selected_cards.size < CARD_LIMIT
      break if available_cards.empty?

      card = pick_diverse_card(
        available_cards,
        cuisine_counts
      )

      selected_cards << card

      cuisine_counts[card.cuisine] += 1

      available_cards.delete(card)
    end

    selected_cards.shuffle
  end

  def eligible_cards
    budget = @nomikai.budget_per_person
    group_size = @nomikai.group_size

    VibeCard.where(active: true)
            .where(
              "min_budget IS NULL OR min_budget <= ?", budget
            )
            .where(
              "max_budget IS NULL OR max_budget >= ?", budget
            )
            .where(
              "min_group_size IS NULL OR min_group_size <= ?", group_size
            )
            .where(
              "max_group_size IS NULL OR max_group_size >= ?", group_size
            )
            .where.not(image_url: [nil, ""])
  end

  def pick_diverse_card(pool, cuisine_counts)
    pool.min_by do |card|
      cuisine_counts[card.cuisine]
    end
  end
end
