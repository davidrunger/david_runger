# frozen_string_literal: true

ActiveAdmin.register(Request) do
  index do
    id_column
    column :user
    column :auth_token
    column :handler
    column :requested_at
    column :location
    column :isp
    column :user_agent
  end
end
