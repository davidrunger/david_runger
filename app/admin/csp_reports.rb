ActiveAdmin.register(CspReport) do
  decorate_with CspReportDecorator

  index do
    id_column
    column :created_at
    column :ip
    column :pretty_user_agent
    column :violated_directive
    column :blocked_uri
    column :document_uri
    column :referrer
    column :original_policy
  end

  show do
    attributes_table do
      row :document_uri
      row :violated_directive
      row :pretty_user_agent
      row :user_agent
      row :original_policy
      row :ip
      row :referrer
      row :blocked_uri

      row :created_at
      row :updated_at
    end

    panel 'Requests with same IP' do
      requests =
        Request.
          where(ip: resource.ip).
          order(id: :desc).
          includes(:admin_user, :auth_token, :user)

      paginated_collection(requests.page(params[:page]).per(15)) do
        table_for(collection.decorate, sortable: false) do
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
