module SidekiqExt ; end

class SidekiqExt::JobArgumentsFormatter
  MAX_LOG_LENGTH = 140

  def call(arguments)
    json = JSON.dump(filtered(arguments))
    json.size <= MAX_LOG_LENGTH ? json : "#{json[0...MAX_LOG_LENGTH]}...]"
  end

  private

  def filtered(value)
    case value
    when String
      value.match?(/[[:space:]]/) ? "[FILTERED: #{value.bytesize} bytes]" : value
    when Array
      value.map { filtered(it) }
    when Hash
      value.transform_values { filtered(it) }
    else
      value
    end
  end
end
