# frozen_string_literal: true

require Rails.root.join('db/datamigrate/transfer_requests_created_at_to_requested_at')

class ChangeTimestampsOnRequests < ActiveRecord::Migration[5.1]
  def up
    add_column :requests, :requested_at, :datetime
    transfer_requests_created_at_to_requested_at
    change_column :requests, :requested_at, :datetime, null: false
    add_index :requests, :requested_at

    remove_column :requests, :created_at, :datetime, null: false
    remove_column :requests, :updated_at, :datetime, null: false
  end

  def down
    add_column :requests, :created_at, :datetime
    add_column :requests, :updated_at, :datetime
    remove_column :requests, :requested_at, :datetime
  end
end
