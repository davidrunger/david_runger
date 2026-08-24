ActiveAdmin.register(LinkStatusExpectation) do
  permit_params :status, :url

  filter :url
  filter :created_at
  filter :updated_at

  index do
    id_column
    column :url
    column :status
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :url
      row :status
      row :created_at
      row :updated_at
    end

    active_admin_comments_for(resource)
  end
end
