# frozen_string_literal: true

# rubocop:disable Rails/ReversibleMigrationMethodDefinition
class CreateActiveAdminComments < ActiveRecord::Migration[6.1]
  def self.up
    create_table :active_admin_comments do |t|
      t.string :namespace
      t.text   :body
      t.references :resource, polymorphic: true
      t.references :author, polymorphic: true
      t.timestamps
    end
    add_index :active_admin_comments, [:namespace]
  end

  def self.down
    drop_table :active_admin_comments
  end
end
# rubocop:enable Rails/ReversibleMigrationMethodDefinition
