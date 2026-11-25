class AddCuratedPhotoMetadataToVibeCards < ActiveRecord::Migration[8.1]
  def change
    add_column :vibe_cards, :image_type, :string
    add_column :vibe_cards, :source_key, :string
    add_column :vibe_cards, :source_url, :string
    add_column :vibe_cards, :license_url, :string
    add_column :vibe_cards, :photographer, :string
    add_index :vibe_cards, :source_key, unique: true
  end
end
