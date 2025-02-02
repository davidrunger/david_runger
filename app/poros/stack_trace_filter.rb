class StackTraceFilter
  def application_stack_trace
    caller.drop(1).select do |caller_line|
      caller_line.exclude?('/gems/') &&
        caller_line.exclude?('/lib/ruby/') &&
        caller_line.exclude?('/middleware/') &&
        caller_line.exclude?(__FILE__)
    end.presence || caller
  end
end
