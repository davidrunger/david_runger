# This monkeypatch makes it so that the repeated calls (if the expectation is
# not initially satisfied) in a `wait_for` block don't get flagged as an N + 1
# query by Prosopite.

if defined?(RSpec::Wait::Handler) && defined?(Prosopite)
  module RSpecWaitHandlerPatches
    # We are monkeypatching this method:
    # https://github.com/laserlemon/rspec-wait/blob/v1.0.1/lib/rspec/wait/handler.rb#L11-L31
    def handle_matcher(target, initial_matcher, message, &block)
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      answer = nil

      Prosopite.pause do
        matcher = RSpec.configuration.clone_wait_matcher ? initial_matcher.clone : initial_matcher

        grandfather_method = method(:handle_matcher).super_method.super_method

        answer =
          if (
            matcher.respond_to?(:supports_block_expectations?) &&
            matcher.supports_block_expectations?
          )
            # simplecov:disable
            grandfather_method.call(
              target,
              matcher,
              message,
              &block
            )
            # simplecov:enable
          else
            grandfather_method.call(
              target.call,
              matcher,
              message,
              &block
            )
          end
      rescue RSpec::Expectations::ExpectationNotMetError
        if RSpec.world.wants_to_quit
          # simplecov:disable
          raise
          # simplecov:enable
        end

        elapsed_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
        if elapsed_time > RSpec.configuration.wait_timeout
          raise
        end

        sleep(RSpec.configuration.wait_delay)
        retry
      end

      answer
    end
  end

  RSpec::Wait::Handler.prepend(RSpecWaitHandlerPatches)
end
