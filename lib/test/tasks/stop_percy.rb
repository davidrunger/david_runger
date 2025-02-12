class Test::Tasks::StopPercy < Pallets::Task
  include Test::TaskHelpers

  def run
    if ENV['PERCY_TOKEN'].present?
      execute_system_command('./node_modules/.bin/percy exec:stop')
    else
      puts('Percy token was not present; skipping stop.')
    end
  end
end
