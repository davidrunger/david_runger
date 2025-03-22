class Logs::UploadsController < ApplicationController
  def new
    authorize(LogEntry, :new?)
    render :new
  end

  def create
    authorize(LogEntry)
    log = current_user.logs.find(params['log_id'])
    log_entries =
      CSV.parse(params['csv'].read, headers: true).map do |row|
        attributes = row.to_h
        created_at_string = attributes['created_at']
        created_at = (Time.iso8601(created_at_string) rescue Date.iso8601(created_at_string))
        attributes['created_at'] = created_at
        attributes['updated_at'] = created_at
        log.build_log_entry_with_datum(attributes)
      end

    if log_entries.all?(&:valid?)
      log_entries.each do |log_entry|
        CreateLogEntry.
          perform_async(
            log_entry.
              attributes.
              merge(
                log_entry.
                  log_entry_datum.
                  attributes.
                  slice('data'),
              ).
              compact.
              to_json,
          )
      end
      flash[:notice] = 'Data uploaded successfully! Give it a moment to enter the database.'
      redirect_to(log_path(slug: log.slug))
    else
      flash[:alert] = 'The uploaded data is invalid. We have not entered it in the database.'
      redirect_to(logs_uploads_path)
    end
  end
end
