class Test::Tasks::WaitForPercyStart < Pallets::Task
  include Test::TaskHelpers

  def run
    if ENV['PERCY_TOKEN'].present?
      # Make up to 20 attempts to verify that Percy is running. (It tends to
      # take particularly long if there is a new Chromium version to download.)
      num_attempts = 20

      num_attempts.times do |index|
        if system('./node_modules/.bin/percy exec:ping')
          record_success_and_log_message("Percy is running after #{index + 1} check(s).")

          break
        elsif index == num_attempts - 1
          record_failure_and_log_message(<<~LOG)
            Percy is still not running after #{index + 1} attempt(s).
          LOG
        end
      end
    else
      record_success_and_log_message('Percy token was not present; skipping percy exec:ping.')
    end
  end
end
