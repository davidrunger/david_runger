ActiveAdmin.register(Event) do
  decorate_with EventDecorator
  includes :admin_user, :user

  index do
    id_column
    column :type
    column :user
    column :data
    column :isp
    column :location
    column :created_at
    column :pretty_user_agent
  end

  show do
    attributes_table do
      row :id
      row :type
      row :user
      row :admin_user
      row :data
      row :ip
      row :isp
      row :location
      row :stack_trace
      row :user_agent
      row :pretty_user_agent
      row :created_at
      row :updated_at
    end

    active_admin_comments_for(resource)
  end
end
