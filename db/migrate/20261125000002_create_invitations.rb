class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations do |t|
      t.references :nomikai, null: false, foreign_key: true
      t.string :email, null: false
      t.string :token, null: false
      t.string :status, null: false, default: "pending"
      t.datetime :sent_at
      t.datetime :accepted_at

      t.timestamps
    end

    add_index :invitations, :token, unique: true
    add_index :invitations, %i[nomikai_id email], unique: true

    add_reference :participants, :invitation, foreign_key: true, index: { unique: true }
  end
end
