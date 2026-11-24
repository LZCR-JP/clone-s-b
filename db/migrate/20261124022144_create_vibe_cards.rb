class CreateVibeCards < ActiveRecord::Migration[8.1]
  def change
    create_table :vibe_cards do |t|
      t.string :title
      t.string :image_url
      t.jsonb :vibe_scores, null: false, default: {}
      t.text :description
      t.integer :min_budget
      t.integer :max_budget
      t.integer :min_group_size
      t.integer :max_group_size
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
