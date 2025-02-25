class AddUserAgentToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :user_agent, :text
  end
end
