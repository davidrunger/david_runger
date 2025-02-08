ActiveAdmin.register(IpBlock) do
  permit_params :ip, :reason

  index do
    id_column
    column :ip
    column(:reason, class: 'pre-wrap')
    column :isp
    column :location
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :ip
      row(:reason, class: 'pre-wrap')
      row :isp
      row :location
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end
end
