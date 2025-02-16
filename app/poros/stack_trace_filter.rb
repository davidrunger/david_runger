class StackTraceFilter
  def application_stack_trace(ignore: [])
    caller.select do |caller_line|
      caller_line.exclude?('/gems/') &&
        caller_line.exclude?('/lib/ruby/') &&
        caller_line.exclude?('/middleware/') &&
        caller_line.exclude?(__FILE__) &&
        ignore.all? { caller_line.exclude?(it) }
    end.presence || caller
  end
end
