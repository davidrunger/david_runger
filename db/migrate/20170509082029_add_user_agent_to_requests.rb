# frozen_string_literal: true

class AddUserAgentToRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :requests, :user_agent, :string
  end
end
