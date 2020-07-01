# frozen_string_literal: true

class AddViewedAtToStores < ActiveRecord::Migration[5.1]
  def change
    add_column :stores, :viewed_at, :datetime
  end
end
