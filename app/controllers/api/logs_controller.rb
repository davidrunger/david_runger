# frozen_string_literal: true

class Api::LogsController < ApplicationController
  before_action :set_log, only: %i[destroy]

  def create
    @log = current_user.logs.build(log_params)
    if @log.save
      StatsD.increment('logs.create.success')
      render json: @log, status: :created
    else
      StatsD.increment('logs.create.failure')
      Rails.logger.info(<<~LOG.squish)
        Failed to create log.
        errors=#{@log.errors.to_hash}
        attributes=#{@log.attributes}
      LOG
      render json: {errors: @log.errors.to_hash}, status: :unprocessable_entity
    end
  end

  def destroy
    @log = current_user.logs.find(params[:id])
    @log.destroy!
    head(204)
  end

  private

  def log_params
    params.require(:log).permit(
      :data_label,
      :data_type,
      :description,
      :name,
    )
  end

  def set_log
    @log ||= current_user.logs.find_by(id: params['id'])
    head(404) if @log.nil?
  end
end
