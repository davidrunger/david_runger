class StackTraceFilter
  def initialize(stack_trace)
    @stack_trace = stack_trace
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def application_stack_trace(ignore: [])
    @stack_trace.select do |caller_line|
      caller_line.include?('/david_runger/') &&
        caller_line.exclude?('/gems/') &&
        caller_line.exclude?('/lib/ruby/') &&
        caller_line.exclude?('/middleware/') &&
        caller_line.exclude?(__FILE__) &&
        ignore.all? { caller_line.exclude?(it) }
    end.presence || caller
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
end
