class Api::LogEntriesController < ApplicationController
  def create
    log = current_user.logs.find(params.dig(:log_entry, :log_id))
    log_entry_params =
      params.require(:log_entry).permit(:log_id, data: log.log_inputs.pluck(:label)).to_h
    @log_entry = log.log_entries.build(log_entry_params)
    if @log_entry.save
      render json: @log_entry
    else
      render json: {errors: @log_entry.errors.to_h}, status: :unprecessable_entity
    end
  end

  def destroy
    log_entry = LogEntry.find(params['id'])
    log_entry.destroy!
    render json: log_entry
  end
end
