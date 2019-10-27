# frozen_string_literal: true

class Middleware::SidekiqDevLogging
  def call(worker, item, queue, &blk)
    start = Time.current
    begin
      log_verbose(worker, item, queue, start, &blk)
    # rubocop:disable Lint/RescueException
    rescue Exception
      # rubocop:enable Lint/RescueException
      logger.info("fail: #{elapsed(start)} sec #{' ! ' * 20}\n\n".red)
      raise
    end
  end

  private

  def log_verbose(worker, item, queue, start)
    logger.info("start           #{' ▽ ' * 12}".red)
    # the extra newline at the beginning of this string has a purpose, to left-align the
    # worker class name in the terminal, rather than having it to the right of the tagged
    # logging output
    puts(<<~START_LOG.rstrip.freeze)
      [#{queue.blue}] [#{worker.class.name.green}] [#{item['jid'].cyan}] [#{item['args'].to_s.yellow}]:
    START_LOG
    yield
    logger.info(format("done: %.3f sec #{' △ ' * 12}\n\n", elapsed(start)).red)
  end

  def elapsed(start)
    [(Time.current - start), 0.001].max.round(3)
  end

  def logger
    Sidekiq.logger
  end
end
