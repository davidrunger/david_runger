# frozen_string_literal: true

class CreateDeploys < ActiveRecord::Migration[7.0]
  def change
    create_table :deploys do |t|
      t.string :git_sha, null: false, index: true

      t.timestamps
    end
  end
end
