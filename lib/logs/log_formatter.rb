# frozen_string_literal: true

class Logs::LogFormatter < Lograge::Formatters::KeyValue
  def initialize(data)
    controller = data.delete(:controller) # e.g. 'Api::LogEntriesController'
    action = data[:action] # e.g. 'index'

    # convert to 'api/log_entries#index'
    if controller && action
      data[:action] = "#{controller.delete_suffix('Controller').underscore}##{action}"
    end

    @data =
      data.
        sort_by.
        with_index do |(key, _value), index|
          case key
          when :path then 0
          when :method then 1
          else index
          end
        end.to_h
  end

  def call
    log_message = super(@data)
    Rails.env.development? ? "#{log_message.red}\n\n" : log_message
  end
end
