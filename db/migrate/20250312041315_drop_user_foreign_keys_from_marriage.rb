class DropUserForeignKeysFromMarriage < ActiveRecord::Migration[8.0]
  def up
    remove_foreign_key(:marriages, column: :partner_1_id)
    remove_foreign_key(:marriages, column: :partner_2_id)

    remove_index :marriages, name: 'index_marriages_on_partner_1_id'
    remove_index :marriages, name: 'index_marriages_on_partner_2_id'

    remove_column :marriages, :partner_1_id
    remove_column :marriages, :partner_2_id
  end

  def down
    raise(
      ActiveRecord::IrreversibleMigration,
      'Cannot restore the partner columns because the data has been lost.',
    )
  end
end
