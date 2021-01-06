# frozen_string_literal: true

class ChangeIpBlockIpFromTextToString < ActiveRecord::Migration[6.1]
  def change
    reversible do |direction|
      change_table :ip_blocks do |t|
        direction.up { t.change :ip, :string }
        direction.down { t.change :ip, :text }
      end
    end
  end
end
