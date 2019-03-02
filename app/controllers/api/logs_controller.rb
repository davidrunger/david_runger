class Api::LogsController < ApplicationController
  def create
    @log = current_user.logs.build(log_params)
    if @log.save
      StatsD.increment('logs.create.success')
      render json: @log
    else
      StatsD.increment('logs.create.failure')
      Rails.logger.info("Failed to create log. errors=#{@log.errors.to_h} log=#{@log.attributes}")
      render json: {errors: @log.errors.to_h}, status: :unprocessable_entity
    end
  end

  private

  def log_params
    params.require(:log).permit(:name, log_inputs_attributes: %i[index label public_type])
  end
end
