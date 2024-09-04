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
            logs: %i[log_entries log_shares],
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
    active_admin_comments
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
