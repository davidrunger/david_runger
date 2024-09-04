class LogEntries::Update < ApplicationAction
  requires :log_entry, LogEntry
  requires :params, ActionController::Parameters

  fails_with :update_failed

  def execute
    update_succeeded =
      ApplicationRecord.transaction do
        log_entry.update!(params.except(:data))
        log_entry.log_entry_datum.update!(data: params[:data])

        true
      rescue
        raise(ActiveRecord::Rollback)
      end

    if !update_succeeded
      result.update_failed!
    end
  end
end
