ActiveAdmin.register(Deploy) do
  decorate_with DeployDecorator
  menu parent: 'Admin'

  index do
    id_column
    column :github_commit_link
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :github_commit_link
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end
end
