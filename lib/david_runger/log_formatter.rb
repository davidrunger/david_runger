# frozen_string_literal: true

class DavidRunger::LogFormatter < Lograge::Formatters::KeyValue
  def initialize(data)
    controller = data.delete(:controller) # e.g. 'Api::LogEntriesController'
    action = data[:action] # e.g. 'index'

    # convert to 'api/log_entries#index'
    if controller && action
      data[:action] = "#{controller.delete_suffix('Controller').underscore}##{action}"
    end

    @data = data
  end

  def call
    super(@data) # use the Lograge::Formatters::KeyValue#call method
  end
end
