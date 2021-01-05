# frozen_string_literal: true

ActiveAdmin.register(Request) do
  decorate_with RequestDecorator
  includes :admin_user, :auth_token, :user

  index do
    id_column
    column :user
    column :admin_user
    column :auth_token
    column :handler
    column :requested_at
    column :location
    column :isp
    column :pretty_user_agent
  end

  show do
    attributes_table do
      row :id
      row :requested_at
      row :handler
      row :url
      row :user
      row :admin_user
      row :auth_token
      row :user_agent
      row :location
      row :isp
      row :ip
      # simply calling `method` causes a bug (that gets interpreted as a Ruby "method" or something)
      row(:method) { |request| request.read_attribute(:method) }
      row :format
      row :params
      row :referer
      row :status
      row :db
      row :view
      row :request_id
    end
    active_admin_comments
  end
end
