class Datamigration
  prepend Memoization

  private

  def logging_start_and_finish
    log('Starting...')

    yield

    log('Finished.')
  end

  def within_transaction(rollback: false)
    ApplicationRecord.transaction do
      yield

      if rollback
        log('Rolling back...')

        raise(ActiveRecord::Rollback)
      end
    end
  end

  def log(message)
    logger.info(message)
  end

  memoize \
  def logger
    ActiveSupport::Logger.new($stdout).tap do |logger|
      logger.formatter =
        proc do |_severity, time, _program_name, message|
          "#{time.utc.iso8601(3)} #{message}\n"
        end
    end.then do |logger|
      ActiveSupport::TaggedLogging.new(logger)
    end.
      tagged(self.class.name)
  end
end
