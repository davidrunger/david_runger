# frozen_string_literal: true

class MakeRequestColumnsNonNullable < ActiveRecord::Migration[5.1]
  def change
    change_column :requests, :url, :string, null: false
    change_column :requests, :handler, :string, null: false
  end
end
