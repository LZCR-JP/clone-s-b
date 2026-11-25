class AddJoinCodeToNomikais < ActiveRecord::Migration[8.1]
  ALPHABET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789".chars.freeze
  LENGTH = 6

  class MigrationNomikai < ActiveRecord::Base
    self.table_name = "nomikais"
  end

  def up
    add_column :nomikais, :join_code, :string

    MigrationNomikai.reset_column_information
    MigrationNomikai.where(join_code: nil).find_each do |nomikai|
      code = loop do
        candidate = Array.new(LENGTH) { ALPHABET.sample(random: SecureRandom) }.join
        break candidate unless MigrationNomikai.exists?(join_code: candidate)
      end
      nomikai.update_columns(join_code: code)
    end

    change_column_null :nomikais, :join_code, false
    add_index :nomikais, :join_code, unique: true
  end

  def down
    remove_index :nomikais, :join_code
    remove_column :nomikais, :join_code
  end
end
