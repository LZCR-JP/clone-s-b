class RestaurantSearchIntent
  MODEL = "gpt-6.2-astra"

  INSTRUCTIONS = <<~TEXT
    Create one concise search query for finding restaurants with Google Places.
    Use the event area and liked vibes to suggest cuisine or atmosphere terms.
    Use disliked vibes to guide what styles to avoid.
    Do not name specific restaurants.
    Do not claim a restaurant is safe for a dietary restriction.
    Return only the query, with no explanation.
  TEXT

  def initialize(nomikai)
    @nomikai = nomikai
  end

  def call
    ::RubyLLM.chat(model: MODEL).ask(prompt).content.strip
  end

  private

  def prompt
    "#{INSTRUCTIONS}\nEvent preferences:\n#{JSON.generate(preferences)}"
  end

  def preferences
    summary = NomikaiPreferenceSummary.new(@nomikai).call
    summary.slice(:area, :liked_vibes, :disliked_vibes)
  end
end
