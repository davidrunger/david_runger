class LogEntries::CreateFromParam < ApplicationAction
  requires :log, Log
  requires :param, String

  def execute
    if log.data_type == 'number' && param.match?(/\s+/)
      data, note = param.split(/\s+/, 2)
    else
      data = param
    end

    log_entry = log.log_entries.build(data:, note:)
    LogEntries::Save.run!(log_entry:)
  end
end
