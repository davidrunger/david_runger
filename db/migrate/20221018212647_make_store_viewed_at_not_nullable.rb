# frozen_string_literal: true

class MakeStoreViewedAtNotNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null :stores, :viewed_at, false
  end
end
