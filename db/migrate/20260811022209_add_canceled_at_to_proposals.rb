class AddCanceledAtToProposals < ActiveRecord::Migration[8.1]
  def up
    add_column :proposals, :canceled_at, :datetime

    remove_index :proposals, name: 'uniq_pending_proposals'
    add_index(
      :proposals,
      %i[proposer_id proposee_email],
      unique: true,
      where: 'accepted_at IS NULL AND canceled_at IS NULL',
      name: 'uniq_pending_proposals',
    )
  end

  def down
    remove_index :proposals, name: 'uniq_pending_proposals'
    remove_column :proposals, :canceled_at
    add_index(
      :proposals,
      %i[proposer_id proposee_email],
      unique: true,
      where: 'accepted_at IS NULL',
      name: 'uniq_pending_proposals',
    )
  end
end
