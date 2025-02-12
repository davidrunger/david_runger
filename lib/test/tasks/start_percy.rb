class Test::Tasks::StartPercy < Pallets::Task
  include Test::TaskHelpers

  def run
    if ENV['PERCY_TOKEN'].present?
      execute_detached_system_command('./node_modules/.bin/percy exec:start')
    else
      record_success_and_log_message('Percy token was not present; skipping percy exec:start.')
    end
  end
end
