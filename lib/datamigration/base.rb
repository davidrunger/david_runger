class Datamigration::Base
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
    logger_base.then do |logger|
      ActiveSupport::TaggedLogging.new(logger)
    end.
      tagged(self.class.name)
  end

  memoize \
  def logger_base
    if Rails.env.development?
      # In development, Rails.logger doesn't log to stdout, but we want to do so here.
      ActiveSupport::Logger.new($stdout).tap do |logger|
        logger.formatter = ActiveSupport::Logger::SimpleFormatter.new
      end
    else
      # In test, we don't want to write to stdout, and Rails.logger doesn't.
      # In production, we do want to write to stdout, and Rails.logger does.
      Rails.logger
    end
  end
end
