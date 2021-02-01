# frozen_string_literal: true

require Rails.root.join('db/datamigrate/populate_banned_path_fragments.rb')

class CreateBannedPathFragments < ActiveRecord::Migration[6.1]
  def change
    create_table :banned_path_fragments do |t|
      t.string :value, null: false
      t.text :notes

      t.timestamps
    end

    up_only do
      populate_banned_path_fragments
    end
  end
end
