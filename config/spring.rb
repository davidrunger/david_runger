# https://github.com/rails/spring-watcher-listen/issues/15#issuecomment-567603693
module SpringWatcherListenIgnorer
  def start
    # :nocov:
    super
    listener.ignore(%r{
      ^(
      .bundle/
      .github/
      coverage/|
      db/|
      log/|
      node_modules/|
      personal/|
      spec/fixtures/|
      tmp/
      )
    }x)
    # :nocov:
  end
end
Spring::Watcher::Listen.prepend(SpringWatcherListenIgnorer)

Spring.watch(*%w[.ruby-version .rbenv-vars tmp/restart.txt tmp/caching-dev.txt])

Spring.after_fork do
  # Disconnect any existing connections inherited from the parent process.
  ActiveRecord::Base.connection_pool.disconnect!

  # Update the database name with the current DB_SUFFIX.
  test_db_config = ActiveRecord::Base.configurations.find_db_config('test')
  test_db_config._database = "david_runger_test#{ENV.fetch('DB_SUFFIX', nil)}"

  # Re-establish the connection with the updated configuration.
  ActiveRecord::Base.establish_connection(test_db_config)

  if Rails.env.test?
    # This essentially duplicates code in config/environments/test.rb.
    ActionMailer::Base.default_url_options = {
      host: 'localhost',
      port: Integer(ENV.fetch('CAPYBARA_SERVER_PORT', 3001)),
    }
  end

  if defined?(Capybara)
    # This duplicates code in spec/spec_helper.rb.
    capybara_port = Integer(ENV.fetch('CAPYBARA_SERVER_PORT', 3001))
    Capybara.server_port = capybara_port
    Capybara.app_host = "http://localhost:#{capybara_port}"
  end
end
