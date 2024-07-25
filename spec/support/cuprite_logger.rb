require 'rainbow/refinement'

using Rainbow

class CupriteLogger
  JSON_EXTRACTION_REGEX = /\A\s*[▶◀]\s+\d+\.\d+ ({.*})\n?\z/
  LOG_MESSAGES_TO_IGNORE = [
    /\A\[vite\] connecting\.\.\.\z/,
  ].freeze
  RUNTIME_CONSOLE_API_CALLED = '"Runtime.consoleAPICalled"'.freeze
  RUNTIME_EXCEPTION_THROWN = '"Runtime.exceptionThrown"'.freeze

  def self.javascript_errors
    @javascript_errors ||= []
  end

  # rubocop:disable Metrics/CyclomaticComplexity
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

      full_stack_trace = parsed_json.dig(
        'params',
        'exceptionDetails',
        'stackTrace',
        'callFrames',
      ).map { _1.values_at('functionName', 'url') }

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
      args_values = args.pluck('value')

      if LOG_MESSAGES_TO_IGNORE.none? { _1.match?(args_values.first.to_s) }
        $stdout.send(:print, "JavaScript console.#{type} argument(s): ")
        $stdout.send(:ap, args_values)
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
end
