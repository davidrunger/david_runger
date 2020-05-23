# frozen_string_literal: true

class AddUniqueIndexOnIpBlocksIp < ActiveRecord::Migration[6.1]
  def change
    add_index :ip_blocks, :ip, unique: true
  end
end
