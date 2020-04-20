# frozen_string_literal: true

class CreateLogShares < ActiveRecord::Migration[6.1]
  def change
    create_table :log_shares do |t|
      # don't index because we add a multi-column index below
      t.references :log, null: false, foreign_key: true, index: false
      t.text :email, null: false

      t.timestamps
    end

    add_index :log_shares, %i[log_id email], unique: true
  end
end
