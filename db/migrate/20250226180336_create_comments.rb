class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.string :path, null: false
      t.text :content, null: false
      t.references :user, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: 'comments' }

      t.timestamps
    end

    add_index :comments, :path
  end
end
