class Logs::UploadsController < ApplicationController
  def new
    authorize(LogEntry, :new?)
    render :new
  end

  def create
    authorize(LogEntry)
    log = current_user.logs.find(params.expect('log_id'))
    result = LogEntries::EnqueueFromCsv.new!(
      csv_path: params.expect('csv').tempfile.path,
      log:,
    ).run

    if result.success?
      flash[:notice] = 'Data uploaded successfully! Give it a moment to enter the database.'
      redirect_to(log_path(slug: log.slug))
    else
      flash[:alert] = result.error_message
      redirect_to(logs_uploads_path)
    end
  end
end
