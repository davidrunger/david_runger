# frozen_string_literal: true

require Rails.root.join('db/datamigrate/set_default_ip_value_for_old_requests')

class AddIpToRequests < ActiveRecord::Migration[5.1]
  def up
    add_column :requests, :ip, :string
    set_default_ip_value_for_old_requests
    change_column :requests, :ip, :string, null: false
  end

  def down
    remove_column :requests, :ip
  end
end
