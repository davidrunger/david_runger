class CreateProposals < ActiveRecord::Migration[8.1]
  def change
    create_table :proposals do |t|
      t.references :proposer, null: false, foreign_key: { to_table: :users }
      t.string :proposee_email, null: false
      t.string :public_id, null: false
      t.datetime :accepted_at

      t.timestamps
    end

    add_index :proposals, :public_id, unique: true
    add_index(
      :proposals,
      %i[proposer_id proposee_email],
      unique: true,
      where: 'accepted_at IS NULL',
      name: 'uniq_pending_proposals',
    )
  end
end
