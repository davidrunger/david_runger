class Test::Tasks::StartPercy < Pallets::Task
  include Test::TaskHelpers

  def run
    if ENV['PERCY_TOKEN'].present?
      execute_detached_system_command('./node_modules/.bin/percy exec:start')
    else
      puts('Percy token was not present; skipping start.')
    end
  end
end
