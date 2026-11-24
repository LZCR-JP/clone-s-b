class CreateNomikais < ActiveRecord::Migration[8.1]
  def change
    create_table :nomikais do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :area
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.datetime :event_date
      t.integer :group_size
      t.integer :budget_per_person
      t.string :status, null: false, default: "open"
      t.string :share_token
      t.text :preference_summary

      t.timestamps
    end
    add_index :nomikais, :share_token, unique: true
  end
end
