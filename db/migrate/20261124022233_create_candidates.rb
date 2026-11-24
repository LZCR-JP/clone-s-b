class CreateCandidates < ActiveRecord::Migration[8.1]
  def change
    create_table :candidates do |t|
      t.references :nomikai, null: false, foreign_key: true
      t.references :venue, null: false, foreign_key: true
      t.decimal :score, precision: 5, scale: 2
      t.integer :rank
      t.text :reason
      t.boolean :selected, null: false, default: false

      t.timestamps
    end

    add_index :candidates, [:nomikai_id, :venue_id], unique: true
  end
end
