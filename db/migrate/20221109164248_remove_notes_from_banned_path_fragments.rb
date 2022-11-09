# frozen_string_literal: true

class RemoveNotesFromBannedPathFragments < ActiveRecord::Migration[7.0]
  def change
    remove_column :banned_path_fragments, :notes, :text
  end
end
