require 'rainbow/refinement'

using Rainbow

class Cuprite::BrowserLogger
  JSON_EXTRACTION_REGEX = /\A\s*[▶◀]\s+\d+\.\d+ ({.*})\n?\z/
  LOG_MESSAGES_TO_IGNORE = [
    /\A\[vite\] connecting\.\.\.\z/,
    /\A\[vite\] connected\.\z/,
  ].freeze
  RUNTIME_CONSOLE_API_CALLED = '"Runtime.consoleAPICalled"'
  RUNTIME_EXCEPTION_THROWN = '"Runtime.exceptionThrown"'

  def self.javascript_errors
    @javascript_errors ||= []
  end

  def self.javascript_logs
    @javascript_logs ||= []
  end

  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/MethodLength
  def puts(message)
    # The message can be an Integer if an integer is logged in JavaScript.
    if !message.is_a?(String)
      return
    end

    if message&.include?(RUNTIME_EXCEPTION_THROWN) && (match = message.match(JSON_EXTRACTION_REGEX))
      parsed_json = JSON.parse(match[1])
      exception_description = parsed_json.dig(
        'params',
        'exceptionDetails',
        'exception',
        'description',
      )
      exception_message =
        exception_description.
          split("\n").
          take_while { !_1.match?(%r{at .*localhost:\d+/vite(-admin)?/}) }.
          join("\n")

      full_stack_trace = (parsed_json.dig(
        'params',
        'exceptionDetails',
        'stackTrace',
        'callFrames',
      ) || []).map { _1.values_at('functionName', 'url') }

      own_stack_trace = full_stack_trace.filter { _1[1].exclude?('/vite/@fs/') }

      stack_trace = own_stack_trace.presence || full_stack_trace

      formatted_stack_trace =
        stack_trace.map do |function, url|
          path = url.match(%r{http://.*/vite/([^?]+)})&.[](1)

          "  from #{function.presence || '[anonymous function]'} in " \
            "#{path ? "app/javascript/#{path}" : url}"
        end

      $stdout.puts("JavaScript error: #{exception_message}".red)
      $stdout.puts(formatted_stack_trace)

      self.class.javascript_errors << exception_message
    elsif message&.include?(RUNTIME_CONSOLE_API_CALLED) &&
        (match = message.match(JSON_EXTRACTION_REGEX))
      parsed_json = JSON.parse(match[1])
      type, args = parsed_json['params'].values_at('type', 'args')
      args_values = args.map { extract_arg_from_data(_1) }

      if LOG_MESSAGES_TO_IGNORE.none? { _1.match?(args_values.first.to_s) }
        $stdout.send(:print, "JavaScript console.#{type} argument(s): ")
        $stdout.send(:ap, args_values)

        self.class.javascript_logs << args_values
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity

  private

  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/CyclomaticComplexity
  def extract_arg_from_data(arg_data)
    if (value = arg_data['value'])
      if value.is_a?(String) && value.match?(/\A{.*}\z/)
        JSON.parse(value) rescue value
      else
        value
      end
    elsif (properties = arg_data.dig('preview', 'properties'))
      properties.to_h do |property|
        [
          property['name'],
          if property['value'] == 'Object' && property['type'] == 'object'
            'Object (serialize to JSON to view)'
          else
            property['value']
          end,
        ]
      end
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
end
