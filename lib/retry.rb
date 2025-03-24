require 'active_support'
require 'active_support/logger'
require 'active_support/tagged_logging'
require 'memo_wise'

module Retry
  class << self
    prepend MemoWise

    def retrying(times: 2, errors: [StandardError])
      retries = 0

      begin
        yield
      rescue *errors => error
        logger.info("Error: #{error.class} - #{error.message}")

        if retries < times
          logger.info('Retrying...')
          retries += 1
          retry
        else
          logger.info('Retries exhausted; raising.')
          raise(error)
        end
      end
    end

    memo_wise \
    def logger
      ActiveSupport::Logger.new($stdout).tap do |logger|
        logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
      end.then do |logger|
        ActiveSupport::TaggedLogging.new(logger)
      end.
        tagged(name)
    end
  end
end
