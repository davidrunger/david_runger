class Api::WeightLogsController < ApplicationController
  def create
    @weight_log = current_user.weight_logs.create!(weight_log_params)
    render json: @weight_log, status: :created
  end

  private

  def weight_log_params
    params.require(:weight_log).permit(:weight, :note)
  end
end
