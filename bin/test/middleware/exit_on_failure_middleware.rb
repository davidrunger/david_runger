# frozen_string_literal: true

module Test ; end
module Test::Middleware ; end

# rubocop:disable Style/StaticClass
class Test::Middleware::ExitOnFailureMiddleware
  def self.call(_worker, _job, _context)
    yield
  rescue => error
    puts(AmazingPrint::Colors.red(
      "Error occurred ('exited with 1') in Pallets runner: #{error.inspect}",
    ))
    puts(error.backtrace)
    exit(1)
  end
end
# rubocop:enable Style/StaticClass
