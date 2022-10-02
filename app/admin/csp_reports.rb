# frozen_string_literal: true

ActiveAdmin.register(CspReport) do
  menu parent: 'Admin'

  show do
    attributes_table do
      row :document_uri
      row :violated_directive
      row :original_policy
      row :incoming_ip
      row :referrer
      row :blocked_uri

      row :created_at
      row :updated_at
    end

    panel 'Requests with same IP' do
      requests =
        Request.
          where(ip: resource.incoming_ip).
          order(id: :desc).
          includes(:admin_user, :auth_token, :user)

      paginated_collection(requests.page(params[:page]).per(15)) do
        table_for(collection, sortable: false) do
          column :id
          column :user
          column :admin_user
          column :auth_token
          column :handler
          column :requested_at
          column :location
          column :isp
          column :pretty_user_agent
        end
      end
    end

    active_admin_comments
  end
end
