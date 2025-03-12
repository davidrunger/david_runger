class CreateMarriageMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :marriage_memberships do |t|
      t.references :marriage, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :marriage_memberships, :user_id, unique: true
  end
end
