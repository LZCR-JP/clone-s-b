class CreateVenues < ActiveRecord::Migration[8.1]
  def change
    create_table :venues do |t|
      t.string :google_place_id

      t.timestamps
    end
    add_index :venues, :google_place_id, unique: true
  end
end
