class LogEntriesController < ApplicationController
  prepend MemoWise

  def create
    if log && new_entry_param
      authorize(log, :update?)
      LogEntries::CreateFromParam.run!(log:, param: new_entry_param)
      flash[:toast_messages] = ['Log entry created!']
      redirect_to(log_path(log.slug))
    else
      skip_authorization
      flash[:toast_messages] = ['There was something wrong with your request.']
      redirect_to(logs_path)
    end
  end

  private

  memo_wise \
  def log
    auth_token_user&.logs&.find_by(slug: params[:slug].presence)
  end

  memo_wise \
  def new_entry_param
    params[:new_entry].presence
  end
end
