# frozen_string_literal: true

require Rails.root.join('db/datamigrate/destroy_requests_without_user_agent.rb')
require Rails.root.join('db/datamigrate/copy_bot_from_user_agent_string_to_new_column.rb')

class AddBotToRequests < ActiveRecord::Migration[5.1]
  def change
    destroy_requests_without_user_agent
    add_column :requests, :bot, :boolean
    backfill_requests_bot_column
    change_column :requests, :bot, :boolean, default: false, null: false
  end
end
