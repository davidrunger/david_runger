ActiveAdmin.register(BannedPathFragment) do
  permit_params :value

  index do
    id_column
    column :value
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :value
      row :created_at
      row :updated_at
    end
    active_admin_comments_for(resource)
  end
end
