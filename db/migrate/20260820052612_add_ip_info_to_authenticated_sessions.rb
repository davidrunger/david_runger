class AddIpInfoToAuthenticatedSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :authenticated_sessions, :isp, :string
    add_column :authenticated_sessions, :location, :string
  end
end
