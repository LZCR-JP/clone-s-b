class CreateSwipes < ActiveRecord::Migration[8.1]
  def change
    create_table :swipes do |t|
      t.references :participant, null: false, foreign_key: true
      t.references :nomikai_vibe_card, null: false, foreign_key: true
      t.boolean :liked, null: false

      t.timestamps
    end

    add_index :swipes, [:participant_id, :nomikai_vibe_card_id], unique: true
  end
end
