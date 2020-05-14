# frozen_string_literal: true

class AddPubliclyViewableToLogs < ActiveRecord::Migration[6.1]
  def change
    add_column :logs, :publicly_viewable, :boolean, null: false, default: false
  end
end
