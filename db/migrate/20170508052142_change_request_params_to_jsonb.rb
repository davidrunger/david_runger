# frozen_string_literal: true

class ChangeRequestParamsToJsonb < ActiveRecord::Migration[5.1]
  def change
    remove_column :requests, :params, :string
    add_column :requests, :params, :jsonb
  end
end
