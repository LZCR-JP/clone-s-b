class AddLocalPhotoFieldsToVibeCards < ActiveRecord::Migration[8.1]
  def up
    %i[image_type cuisine source_key].each do |column|
      add_column :vibe_cards, column, :string unless column_exists?(:vibe_cards, column)
    end
    add_index :vibe_cards, :source_key, unique: true unless index_exists?(:vibe_cards, :source_key, unique: true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Some columns may predate this migration"
  end
end
