class Api::LogsController < Api::BaseController
  before_action :set_log, only: %i[destroy update]

  def create
    authorize(Log)
    @log = current_user.logs.build(log_params)
    if @log.save
      render json: @log.serializer(own_log: true), status: :created
    else
      errors_hash = @log.errors.to_hash

      Rails.logger.info(<<~LOG.squish)
        Failed to create log.
        errors=#{errors_hash}
        attributes=#{@log.attributes}
      LOG
      render json: { errors: errors_hash }, status: :unprocessable_entity
    end
  end

  def update
    authorize(@log)
    @log.update!(log_params)
    render json: @log.serializer(own_log: true)
  end

  def destroy
    authorize(@log)
    @log.destroy!
    head(:no_content)
  end

  private

  def log_params
    params.require(:log).permit(
      :data_label,
      :data_type,
      :description,
      :name,
      :publicly_viewable,
      :reminder_time_in_seconds,
    )
  end

  def set_log
    @log = current_user.logs.find_by(id: params[:id])
    head(:not_found) if @log.nil?
  end
end
