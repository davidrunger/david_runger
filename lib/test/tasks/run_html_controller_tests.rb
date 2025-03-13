class Test::Tasks::RunHtmlControllerTests < Pallets::Task
  include Test::TaskHelpers

  def run
    # run all tests in `spec/controllers/` _except_ those in `spec/controllers/api/`
    execute_rspec_command(<<~COMMAND)
      DB_SUFFIX=_html
      bin/rspec
      $(ls -d spec/controllers/*/ | grep -v 'spec/controllers/api/')
      $(ls spec/controllers/*.rb)
      $(ls spec/helpers/*.rb)
      $(ls spec/requests/**/*.rb)
      $(ls spec/requests/*.rb)
      #{rspec_output_options}
    COMMAND
  end
end
