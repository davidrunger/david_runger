ActiveAdmin.register(User) do
  permit_params :email
  filter :email
  filter :created_at

  controller do
    def find_resource
      collection = scoped_collection
      if params[:action] == 'destroy'
        collection =
          collection.includes(
            logs: [:log_shares, { log_entries: :log_entry_datum }],
            stores: %i[items],
          )
      end
      collection.find(params[:id])
    end
  end

  show do
    attributes_table do
      row :email
      row :created_at
      row :updated_at
    end

    panel 'Requests' do
      table_for resource.requests.order(requested_at: :desc).limit(10) do
        column :id do |r|
          link_to r.id, admin_request_path(r)
        end
        column :handler
        column :requested_at
      end

      div style: 'margin-top: 10px;' do
        link_to 'View All Requests →', admin_requests_path(q: { user_id_eq: resource.id })
      end
    end

    active_admin_comments_for(resource)
  end

  index do
    id_column
    column :email
    column :created_at
    column :updated_at
    actions
    column { |user| link_to('Become', become_admin_user_path(user)) }
  end

  form do |f1|
    f1.semantic_errors
    active_admin_form_for([:admin, resource]) do |f2|
      f2.inputs(:email)
      f2.actions
    end
  end

  action_item :become, only: :show do
    link_to('Become', become_admin_user_path(resource))
  end

  member_action :become do
    sign_in(resource)
    redirect_to(groceries_path)
  end

  member_action :unbecome do
    sign_out(:user)
    redirect_to(admin_user_path(params[:id]))
  end
end
