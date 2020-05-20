# frozen_string_literal: true

class CreateIpBlocks < ActiveRecord::Migration[6.1]
  def change
    create_table :ip_blocks do |t|
      t.text :ip, null: false
      t.text :reason

      t.timestamps
    end
  end
end
