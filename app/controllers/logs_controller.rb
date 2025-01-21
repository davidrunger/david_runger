class LogsController < ApplicationController
  def index
    @title = 'Logs'

    bootstrap(
      current_user: UserSerializer::Basic.new(current_user),
      logs: LogSerializer.new(
        authorized_logs.order(:name).includes(:log_shares),
        params: { current_user: },
      ),
      log_input_types:,
      log_selector_keyboard_shortcut: LogSelectorKeyboardShortcut.new(browser).shortcut,
    )

    render :index
  end

  private

  def authorized_logs
    if shared_log_path?
      authorize(shared_log, :show?)
      Log.where(id: shared_log)
    else
      authorize(Log, :index?)
      current_user.logs
    end
  end

  def shared_log
    if shared_log_path?
      sharing_user = User.find(user_id_param)
      sharing_user.logs.find_by!(slug: slug_param)
    end
  end

  def shared_log_path?
    user_id_param && slug_param
  end

  def user_id_param
    params[:user_id].presence
  end

  def slug_param
    params[:slug].presence
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
