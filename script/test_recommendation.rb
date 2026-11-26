require "ostruct"

class TestRestaurantSearchIntent < RestaurantSearchIntent
  def initialize(profile)
    @profile = profile
    super(OpenStruct.new(area: profile[:area]))
  end

  private

  def preferences
    @profile
  end
end

def cuisine(rate, participants)
  {
    like_rate: rate,
    participants: participants
  }
end

def vibe(liked, disliked)
  {
    liked_average: liked,
    disliked_average: disliked,
    likes: 12,
    dislikes: 8
  }
end

profiles = [
  {
    name: "Casual company nomikai",
    area: "shibuya",
    group_size: 10,
    effective_budget_per_person: 4000,
    participants_joined: 10,
    participants_completed: 10,
    participants_voted: 10,
    non_drinkers: 1,
    dietary_restrictions: {},

    cuisine_preferences: {
      izakaya: cuisine(90, 10),
      italian: cuisine(40, 10),
      sushi: cuisine(30, 10)
    },

    vibe_evidence: {
      casual: vibe(95, 30),
      lively: vibe(90, 25),
      luxury: vibe(20, 85),
      privacy: vibe(25, 70)
    },

    card_feedback: []
  },

  {
    name: "Premium dinner",
    area: "roppongi",
    group_size: 4,
    effective_budget_per_person: 15000,
    participants_joined: 4,
    participants_completed: 4,
    participants_voted: 4,
    non_drinkers: 0,
    dietary_restrictions: {},

    cuisine_preferences: {
      italian: cuisine(100, 4),
      french: cuisine(75, 4),
      izakaya: cuisine(0, 4)
    },

    vibe_evidence: {
      luxury: vibe(95, 15),
      modern: vibe(90, 20),
      privacy: vibe(85, 25),
      casual: vibe(15, 90),
      lively: vibe(30, 85)
    },

    card_feedback: []
  },

  {
    name: "Korean dinner with dietary restrictions",
    area: "shinjuku",
    group_size: 8,
    effective_budget_per_person: 5000,
    participants_joined: 8,
    participants_completed: 8,
    participants_voted: 8,
    non_drinkers: 2,

    dietary_restrictions: {
      vegetarian: 2
    },

    cuisine_preferences: {
      korean: cuisine(88, 8),
      chinese: cuisine(63, 8),
      bbq: cuisine(25, 8)
    },

    vibe_evidence: {
      casual: vibe(85, 30),
      lively: vibe(80, 35),
      luxury: vibe(25, 80)
    },

    card_feedback: []
  }
]

profiles.each do |profile|
  puts "\n" + "=" * 60
  puts profile[:name]
  puts "=" * 60

  begin
    query = TestRestaurantSearchIntent.new(profile).call

    puts "\nFINAL QUERY:"
    puts query
  rescue StandardError => e
    puts "ERROR: #{e.class}"
    puts e.message
  end
end
