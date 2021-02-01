# frozen_string_literal: true

class AddIndexForBannedPathFragmentsValue < ActiveRecord::Migration[6.1]
  def change
    add_index :banned_path_fragments, :value, unique: true
  end
end
