module Capybara::ActionLogger
  Capybara::Session::DSL_METHODS.each do |method|
    define_method(method) do |*args, **kwargs, &block|
      arguments = capybara_log_value(args)
      keyword_arguments = capybara_log_value(kwargs)
      Rails.logger.info("[Capybara] #{method} args=#{arguments} kwargs=#{keyword_arguments}")

      super(*args, **kwargs, &block)
    end
  end

  private

  def capybara_log_value(value)
    case value
    when Capybara::Node::Base
      "#<#{value.class}>"
    when Array
      "[#{value.map { capybara_log_value(it) }.join(', ')}]"
    when Hash
      log_entries =
        value.map do |key, nested_value|
          "#{capybara_log_key(key)} #{capybara_log_value(nested_value)}"
        end
      "{#{log_entries.join(', ')}}"
    else
      value.inspect
    end
  end

  def capybara_log_key(key)
    return "#{key.name}:" if key.is_a?(Symbol) && key.name.match?(/\A[A-Za-z_]\w*[!?=]?\z/)

    "#{capybara_log_value(key)} =>"
  end
end

Capybara::DSL.prepend(Capybara::ActionLogger)
