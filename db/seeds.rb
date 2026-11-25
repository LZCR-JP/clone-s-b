# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
cards = [
  {
    title: "Casual Izakaya",
    description: "Relaxed and lively Japanese pub",
    min_budget: 1000,
    max_budget: 5000,
    min_group_size: 2,
    max_group_size: 50,
    vibe_scores: {
      casual: 95, luxury: 10, lively: 90,
      modern: 20, privacy: 20, traditional: 90
    }
  },
  {
    title: "Luxury Dining",
    description: "Elegant and sophisticated dining",
    min_budget: 8000,
    max_budget: 50000,
    min_group_size: 2,
    max_group_size: 15,
    vibe_scores: {
      casual: 10, luxury: 95, lively: 20,
      modern: 80, privacy: 70, traditional: 30
    }
  },
  {
    title: "Trendy Restaurant",
    description: "Modern and energetic atmosphere",
    min_budget: 2000,
    max_budget: 15000,
    min_group_size: 2,
    max_group_size: 30,
    vibe_scores: {
      casual: 60, luxury: 50, lively: 80,
      modern: 95, privacy: 20, traditional: 10
    }
  },
  {
    title: "Private Dining",
    description: "Quiet and private dining space",
    min_budget: 3000,
    max_budget: 50000,
    min_group_size: 2,
    max_group_size: 30,
    vibe_scores: {
      casual: 40, luxury: 70, lively: 20,
      modern: 60, privacy: 95, traditional: 50
    }
  },
  {
    title: "Traditional Japanese",
    description: "Authentic Japanese atmosphere",
    min_budget: 2000,
    max_budget: 30000,
    min_group_size: 2,
    max_group_size: 30,
    vibe_scores: {
      casual: 50, luxury: 50, lively: 40,
      modern: 10, privacy: 60, traditional: 95
    }
  },
  {
    title: "Social Bar",
    description: "Energetic and social group setting",
    min_budget: 1000,
    max_budget: 30000,
    min_group_size: 2,
    max_group_size: 50,
    vibe_scores: {
      casual: 85, luxury: 40, lively: 95,
      modern: 70, privacy: 10, traditional: 10
    }
  }
]

cards.each do |attributes|
  card = VibeCard.find_or_initialize_by(
    title: attributes[:title]
  )

  card.update!(attributes.merge(active: true))
end

require "json"

manifest_path = Rails.root.join("db/vibe_cards/local_photos/manifest.json")
raise "Photo manifest not found: #{manifest_path}" unless File.exist?(manifest_path)

photo_rows = JSON.parse(File.read(manifest_path))
recommended_rows = photo_rows.select do |row|
  row["review_status"] == "recommended"
end

cloudinary_base_url = "https://res.cloudinary.com/upyatvpj/image/upload"

recommended_rows.each do |row|
  filename = row.fetch("filename")

  attributes = row.slice(
    "title",
    "description",
    "image_type",
    "cuisine",
    "min_budget",
    "max_budget",
    "min_group_size",
    "max_group_size",
    "vibe_scores"
  ).merge(
    "image_url" => "#{cloudinary_base_url}/#{filename}",
    "active" => true
  )

  card = VibeCard.find_or_initialize_by(
    source_key: row.fetch("source_key")
  )

  card.update!(attributes)
end

puts "Seeded #{recommended_rows.length} recommended photo cards."

puts "#{VibeCard.count} vibe cards available."
