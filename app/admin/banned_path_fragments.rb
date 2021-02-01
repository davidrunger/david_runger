# frozen_string_literal: true

ActiveAdmin.register(BannedPathFragment) do
  permit_params :value, :notes

  index do
    id_column
    column :value
    column(:notes, class: 'pre-wrap')
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :value
      row(:notes, class: 'pre-wrap')
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end
end
