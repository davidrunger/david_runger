# frozen_string_literal: true

class LogEntries::CreateFromParam < ApplicationAction
  requires :log, Shaped::Shape(Log)
  requires :param, Shaped::Shape(String)

  def execute
    if log.data_type == 'number' && param.match?(/\s+/)
      value, note = param.split(/\s+/, 2)
    else
      value = param
    end

    LogEntries::Create.new(log: log, attributes: { value: value, note: note }).run!
  end
end
