if defined?(RSpec::Wait::Handler) && defined?(Prosopite)
  module RSpecWaitHandlerPatches
    # We are monkeypatching this method:
    # https://github.com/laserlemon/rspec-wait/blob/v1.0.1/lib/rspec/wait/handler.rb#L11-L31
    # rubocop:disable Metrics
    def handle_matcher(target, initial_matcher, message, &block)
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      answer = nil

      Prosopite.pause do
        matcher = RSpec.configuration.clone_wait_matcher ? initial_matcher.clone : initial_matcher

        answer =
          if (
            matcher.respond_to?(:supports_block_expectations?) &&
            matcher.supports_block_expectations?
          )
            method(:handle_matcher).super_method.super_method.call(
              target,
              matcher,
              message,
              &block
            )
          else
            method(:handle_matcher).super_method.super_method.call(
              target.call,
              matcher,
              message,
              &block
            )
          end
      rescue RSpec::Expectations::ExpectationNotMetError
        raise if RSpec.world.wants_to_quit

        elapsed_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
        raise if elapsed_time > RSpec.configuration.wait_timeout

        sleep(RSpec.configuration.wait_delay)
        retry
      end

      answer
    end
  end
  # rubocop:enable Metrics

  RSpec::Wait::Handler.prepend(RSpecWaitHandlerPatches)
end
