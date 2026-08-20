module Capybara::ActionLogger
  Capybara::Session::DSL_METHODS.each do |method|
    define_method(method) do |*args, **kwargs, &block|
      Rails.logger.info("[Capybara] #{method} args=#{args.inspect} kwargs=#{kwargs.inspect}")

      super(*args, **kwargs, &block)
    end
  end
end

Capybara::DSL.prepend(Capybara::ActionLogger)
