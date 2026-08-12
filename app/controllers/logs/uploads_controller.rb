class Logs::UploadsController < ApplicationController
  CSV_UPLOAD_LIMIT = 6

  rate_limit(
    to: CSV_UPLOAD_LIMIT,
    within: 1.hour,
    by: -> { current_user.id },
    with: :csv_upload_rate_limit_reached,
    only: :create,
  )

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

  private

  def csv_upload_rate_limit_reached
    redirect_to(
      logs_uploads_path,
      alert: "CSV uploads are limited to #{CSV_UPLOAD_LIMIT} per hour. Please try again later.",
    )
  end
end
