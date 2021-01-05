# frozen_string_literal: true

ActiveAdmin.register(IpBlock) do
  permit_params :ip, :reason

  show do
    attributes_table do
      row :ip
      row(:reason, class: 'pre-wrap')
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end
end
