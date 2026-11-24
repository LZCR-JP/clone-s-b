class CreateParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :participants do |t|
      t.references :nomikai, null: false, foreign_key: true
      t.string :nickname
      t.string :token
      t.integer :budget_max
      t.string :restrictions, array: true, null: false, default: []
      t.boolean :non_drinker, null: false, default: false
      t.datetime :completed_at

      t.timestamps
    end
    add_index :participants, :token, unique: true
  end
end
