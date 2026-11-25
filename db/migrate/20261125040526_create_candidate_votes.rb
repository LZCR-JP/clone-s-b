class CreateCandidateVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :candidate_votes do |t|
      t.references :participant, null: false, foreign_key: true
      t.references :candidate, null: false, foreign_key: true
      t.boolean :approved, null: false

      t.timestamps
    end

    add_index :candidate_votes,
              [:participant_id, :candidate_id],
              unique: true
  end
end
