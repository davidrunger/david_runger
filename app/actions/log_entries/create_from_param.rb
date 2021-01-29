# frozen_string_literal: true

class LogEntries::CreateFromParam < ApplicationAction
  requires :log, Shaped::Shape(Log)
  requires :param, Shaped::Shape(String)

  def execute
    if log.data_type == 'number' && param.match?(/\s+/)
      data, note = param.split(/\s+/, 2)
    else
      data = param
    end

    log_entry = log.log_entries.build(data: data, note: note)
    LogEntries::Save.run!(log_entry: log_entry)
  end
end
