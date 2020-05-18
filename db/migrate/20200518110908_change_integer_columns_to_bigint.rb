# frozen_string_literal: true

class ChangeIntegerColumnsToBigint < ActiveRecord::Migration[6.1]
  def up
    change_column :items, :id, :bigint
    change_column :stores, :id, :bigint
    change_column :items, :store_id, :bigint
    change_column :stores, :user_id, :bigint
  end

  def down
    change_column :items, :id, :integer
    change_column :stores, :id, :integer
    change_column :items, :store_id, :integer
    change_column :stores, :user_id, :integer
  end
end
