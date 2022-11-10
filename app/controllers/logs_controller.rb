# frozen_string_literal: true

class LogsController < ApplicationController
  def index
    authorize(Log)

    if shared_log?
      sharing_user = User.find(user_id_param)
      shared_log = sharing_user.logs.find_by!(slug: slug_param)
      authorize(shared_log, :show?)
      logs = Log.where(id: shared_log)
    else
      current_user_logs = current_user.logs
      logs = current_user_logs.order(:created_at).includes(:log_shares, :user)

      new_entry = params[:new_entry].presence
      if slug_param && new_entry
        verify_valid_auth_token!
        log = current_user_logs.find_by!(slug: slug_param)
        LogEntries::CreateFromParam.run!(log:, param: new_entry)
        bootstrap(toast_messages: ['New Log entry created!'])
      end
    end

    @title = 'Logs'
    bootstrap(
      current_user: UserSerializer.new(current_user),
      logs: LogSerializer.new(logs, params: { own_log: !shared_log? }),
      log_input_types:,
    )
    render :index
  end

  private

  def shared_log?
    user_id_param && slug_param
  end

  def user_id_param
    params[:user_id]
  end

  def slug_param
    params[:slug]
  end

  def log_input_types
    [
      { data_type: 'counter', label: 'Counter' },
      { data_type: 'duration', label: 'Duration' },
      { data_type: 'number', label: 'Number' },
      { data_type: 'text', label: 'Text' },
    ]
  end
end
