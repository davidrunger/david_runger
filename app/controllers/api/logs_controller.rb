class Api::LogsController < Api::BaseController
  before_action :set_log, only: %i[destroy rotate_email_submission_token update]

  def create
    authorize(Log)
    @log = current_user.logs.build(log_params)
    if @log.save
      render_schema_json(@log.serializer(current_user:), status: :created)
    else
      render json: { errors: @log.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    authorize(@log)
    @log.update!(log_params)
    render_schema_json(@log.serializer(current_user:))
  end

  def destroy
    authorize(@log)
    @log.destroy!
    head(:no_content)
  end

  def rotate_email_submission_token
    authorize(@log, :update?)
    @log.rotate_email_submission_token!
    render_schema_json(@log.serializer(current_user:))
  end

  private

  def log_params
    params.expect(
      log: %i[
        data_label
        data_type
        description
        name
        publicly_viewable
        reminder_time_in_seconds
      ],
    )
  end

  def set_log
    @log = current_user.logs.includes(eager_loads).find_by(id: params[:id])

    if @log.nil?
      head(:not_found)
    end
  end

  def eager_loads
    case params[:action]
    in 'destroy' then { log_entries: :log_entry_datum }
    else {}
    end
  end
end
