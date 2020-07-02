# frozen_string_literal: true

class CreateRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :requests do |t|
      t.references :user, foreign_key: true
      t.string :url
      t.string :handler
      t.string :params
      t.string :referer
    end
  end
end
