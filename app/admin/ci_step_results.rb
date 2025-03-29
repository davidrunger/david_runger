ActiveAdmin.register(CiStepResult) do
  decorate_with CiStepResultDecorator
  includes :user

  show title: :name_with_identifiers do
    attributes_table do
      row :id
      row :user

      row :name
      row :seconds
      row :branch
      row :passed
      row :github_run_id
      row :github_run_attempt
      row :started_at
      row :stopped_at
      row :sha

      row :created_at
      row :updated_at
    end

    active_admin_comments_for(resource)
  end
end
