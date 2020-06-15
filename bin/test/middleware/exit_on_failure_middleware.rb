# frozen_string_literal: true

module Test ; end
module Test::Middleware ; end

class Test::Middleware::ExitOnFailureMiddleware
  def self.call(_worker, _job, _context)
    yield
  rescue => error
    puts("Error occurred ('exited with 1') in Pallets runner: #{error.inspect}".red)
    puts(error.backtrace)
    exit(1)
  end
end
