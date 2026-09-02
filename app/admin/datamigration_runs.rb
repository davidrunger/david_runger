ActiveAdmin.register(DatamigrationRun) do
  show do
    attributes_table do
      row :id
      row :name
      row :developer
      row(:created_at) { |datamigration_run| l(datamigration_run.created_at, format: :precise) }
      row(:completed_at) do |datamigration_run|
        datamigration_run.completed_at && l(datamigration_run.completed_at, format: :precise)
      end
      row(:updated_at) { |datamigration_run| l(datamigration_run.updated_at, format: :precise) }
    end
  end
end
