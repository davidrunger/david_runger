class DatamigrationGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def create_datamigration_file
    if behavior == :invoke
      timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
      migration_filename = "#{timestamp}_#{file_name.underscore}.rb"
      template('datamigration_template.tt', "db/datamigrate/#{migration_filename}")
    else
      # In revoke mode, find and remove the most recent matching file.
      datamigration_absolute_path =
        Rails.root.
          glob("db/datamigrate/*_#{file_name.underscore}.rb").
          last

      if datamigration_absolute_path
        datamigration_relative_path = datamigration_absolute_path.relative_path_from(Rails.root)

        say_status('remove', datamigration_relative_path, :red)
        File.delete(datamigration_relative_path)
      end
    end
  end
end
