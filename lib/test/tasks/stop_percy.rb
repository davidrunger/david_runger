class Test::Tasks::StopPercy < Pallets::Task
  include Test::TaskHelpers

  def run
    if ENV['PERCY_TOKEN'].present?
      execute_system_command('./node_modules/.bin/percy exec:stop')
    else
      record_success_and_log_message('Percy token was not present; skipping percy exec:stop.')
    end
  end
end
