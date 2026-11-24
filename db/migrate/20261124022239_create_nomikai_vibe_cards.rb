class CreateNomikaiVibeCards < ActiveRecord::Migration[8.1]
  def change
    create_table :nomikai_vibe_cards do |t|
      t.references :nomikai, null: false, foreign_key: true
      t.references :vibe_card, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end

    add_index :nomikai_vibe_cards, [:nomikai_id, :vibe_card_id], unique: true
  end
end
