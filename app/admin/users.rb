# frozen_string_literal: true

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
            logs: %i[log_shares number_log_entries text_log_entries],
            stores: %i[items],
          )
      end
      collection.find(params[:id])
    end
  end

  index do
    id_column
    column :email
    column :created_at
    column :updated_at
    actions
    column { |user| link_to('Become', become_admin_user_path(user)) }
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
