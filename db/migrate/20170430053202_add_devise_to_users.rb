# frozen_string_literal: true

# rubocop:disable Rails/ReversibleMigrationMethodDefinition
class AddDeviseToUsers < ActiveRecord::Migration[5.1]
  def self.up
    change_table :users do |t|
      ## Database authenticatable
      t.string :encrypted_password, null: false

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip
    end
  end

  def self.down
    raise(ActiveRecord::IrreversibleMigration)
  end
end
# rubocop:enable Rails/ReversibleMigrationMethodDefinition
