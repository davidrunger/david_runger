# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'

module SpecHelper
  class << self
    def is_ci? = ENV.fetch('CI', nil) == 'true'

    def use_headful_chrome? = ENV.fetch('HEADFUL_CHROME', nil).present?
  end
end

require 'simplecov'
SimpleCov.coverage_dir('tmp/simple_cov') # must match codecov-action directory option
SimpleCov.start do
  db_suffix = ENV.fetch('DB_SUFFIX', nil)
  spec_group = ENV.fetch('SPEC_GROUP', nil)
  capybara_server_port = ENV.fetch('CAPYBARA_SERVER_PORT', nil)
  # rubocop:disable Rails/Present -- At this point, we have not yet loaded Rails.
  if !db_suffix.nil? && !db_suffix.empty?
    command_name(
      "Tests on DB #{db_suffix} w/ Capybara port #{capybara_server_port.inspect} " \
      "(spec group: #{spec_group.inspect})",
    )
  end
  # rubocop:enable Rails/Present
  add_filter(%r{^/spec/})
  add_filter(%r{^/tools/(?!custom_cops/)})
  enable_coverage(:branch) if !SpecHelper.is_ci? # Codecov doesn't respect `nocov-else` etc comments
end

require File.expand_path('../config/environment', __dir__)

if SpecHelper.is_ci?
  require 'simplecov-cobertura'
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
elsif RSpec.configuration.files_to_run.one?
  require 'simple_cov/formatter/terminal'
  SimpleCov.formatter = SimpleCov::Formatter::Terminal
  SimpleCov::Formatter::Terminal.config.spec_to_app_file_map.merge!(
    %r{\Aspec/config/initializers/} => 'config/initializers/',
    %r{\Aspec/poros/} => 'app/poros/',
    %r{\Aspec/tools/} => 'tools/',
  )
end

require 'factory_bot_rails'
require 'webmock'
require 'webmock/rspec'
require 'pundit/rspec'
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'capybara/cuprite'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/email/rspec'
require 'capybara-screenshot/rspec' unless SpecHelper.use_headful_chrome?
require 'mail'
require 'percy/capybara'
require 'super_diff/rspec-rails'
require 'paper_trail/frameworks/rspec' # Disables PaperTrail in specs by default.
require Rails.root.join('spec/support/fixture_builder.rb').to_s
Dir['spec/support/**/*.rb'].each { |file| require Rails.root.join(file) }

# w/o this, Sidekiq's `logger` prints to STDOUT (bad); with this, it prints to `log/test.log` (good)
sidekiq_logger = Sidekiq::Logger.new(Rails.root.join('log/test.log').to_s)
# `WithoutTimestamp` is the formatter that Sidekiq uses in production for us
sidekiq_logger.formatter = Sidekiq::Logger::Formatters::WithoutTimestamp.new
Sidekiq.default_configuration.logger = sidekiq_logger

WebMock.enable!
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: 'david-runger-test-uploads.s3.amazonaws.com', # upload feature test failure screenshots
)

OmniAuth.config.test_mode = true

if SpecHelper.is_ci?
  Capybara::Screenshot.s3_configuration = {
    s3_client_credentials: {
      access_key_id: Rails.application.credentials.aws![:access_key_id],
      secret_access_key: Rails.application.credentials.aws![:secret_access_key],
      region: 'us-east-1',
    },
    bucket_name: 'david-runger-test-uploads',
    bucket_host: 'david-runger-test-uploads.s3.amazonaws.com',
    key_prefix: 'failure-screenshots/',
  }
end

Cuprite::CustomDrivers.register_with_capybara
Capybara.default_driver = Cuprite::CustomDrivers::DOMAIN_RESTRICTED_CUPRITE
Capybara.javascript_driver = Cuprite::CustomDrivers::DOMAIN_RESTRICTED_CUPRITE
# allow loading JS & CSS assets via `save_and_open_page` when running `rails s`
Capybara.asset_host = 'http://localhost:3000'
Capybara.server = :puma, { Silent: true }
Capybara.default_normalize_ws = true
# This port matches a config in config/environments/test.rb.
capybara_port = Integer(ENV.fetch('CAPYBARA_SERVER_PORT', 3001))
Capybara.server_port = capybara_port
Capybara.app_host = "http://localhost:#{capybara_port}"

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
# ActiveRecord::Migration.maintain_test_schema!

# This file was generated by the `rails generate rspec:install` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.render_views

  config.fail_if_no_examples = true

  config.global_fixtures = :all

  config.wait_timeout = Integer(ENV.fetch('RSPEC_WAIT_TIMEOUT', 10))

  config.include(SpecHelpers)
  config.include(ActiveSupport::Testing::TimeHelpers)
  config.include(FactoryBot::Syntax::Methods)
  config.include(SidekiqSpecHelpers)
  config.include(Devise::Test::ControllerHelpers, type: :controller)
  config.include(Devise::Test::IntegrationHelpers, type: :feature)
  config.include(Features::DownloadHelpers, type: :feature)
  config.include(Features::SignInHelpers, type: :feature)
  config.include(Monkeypatches::MakeAllRequestsAsJson, request_format: :json)
  config.include(ActionCable::TestHelper, :action_cable_test_adapter)
  config.include(ActionMailbox::TestHelper, type: :mailbox)
  config.include(ActionMailbox::TestHelper, type: :mailer)
  config.include(MailSpecHelpers, type: :mailbox)
  config.include(MailSpecHelpers, type: :mailer)

  # rspec-retry options >>>
  config.verbose_retry = true
  config.display_try_failure_messages = true
  config.around(:each, type: :feature) do |example|
    example.run_with_retry(
      # This actually means 'try: 2', i.e. retry just once.
      retry: 2,
      exceptions_to_retry: [
        Ferrum::ProcessTimeoutError,
        Ferrum::TimeoutError,
      ],
    )
  end
  config.retry_callback =
    proc do |ex|
      if ex.metadata[:type] == :feature
        Capybara.reset!
        page.driver.reset!
        # Force garbage collection to release memory.
        GC.start
      end
    end
  # <<< rspec-retry options

  config.before(:suite) do
    # Reset FactoryBot sequences to an arbitrarily high number to avoid collisions with
    # fixture_builder-built fixtures.
    #
    # It seems naughty to be reaching in to FactoryBot `Internal`s here, but I (Runger) am not sure
    # we have a great alternative available.
    FactoryBot::Internal.configuration.sequences.each do |sequence|
      sequence.instance_variable_set(:@value, FactoryBot::Sequence::EnumeratorAdapter.new(10_000))
    end
    FactoryBot::Internal.inline_sequences.each do |sequence|
      sequence.instance_variable_set(:@value, FactoryBot::Sequence::EnumeratorAdapter.new(10_000))
    end

    # Some of the specs involve somewhat lengthy strings; increase the size of the printed output
    # for easier comparison of expected vs actual strings, in the event of a failure.
    # https://github.com/rspec/rspec-expectations/issues/ 991#issuecomment-302863645
    RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = 2_000
  end

  # Prewarm browsers for feature specs >>>
  if SpecHelper.is_ci?
    def prewarm_driver(driver_name)
      max_retries = 3
      retry_count = 0

      begin
        puts("Pre-warming #{driver_name} Cuprite browser...")

        Capybara.using_driver(driver_name) do
          session = Capybara::Session.new(driver_name)
          url = 'about:blank'
          session.visit(url)
          puts("#{driver_name} Cuprite browser visited #{url} successfully.")
        end
      rescue Ferrum::ProcessTimeoutError => error
        retry_count += 1

        if retry_count <= max_retries
          sleep_time = 2**retry_count # Exponential backoff.
          puts("Browser warm-up failed, retrying in #{sleep_time} seconds...")
          sleep(sleep_time)
          retry
        else
          puts("Failed to pre-warm browser after #{max_retries} attempts.")
          raise(error)
        end
      end
    end

    config.before(:suite) do
      examples = RSpec.world.filtered_examples.values.flatten

      if examples.any? do |example|
        example.metadata[:type] == :feature && !example.metadata[:rack_test_driver]
      end
        if examples.any? { |example| !example.metadata[:permit_all_external_requests] }
          prewarm_driver(Cuprite::CustomDrivers::DOMAIN_RESTRICTED_CUPRITE)
        end

        if examples.any? { |example| example.metadata[:permit_all_external_requests] }
          prewarm_driver(Cuprite::CustomDrivers::UNRESTRICTED_CUPRITE)
        end
      end
    end
  end
  # <<< Prewarm browsers for feature specs

  config.around(:each, type: :feature) do |example|
    $test_log_string_io ||= StringIO.new
    $test_log_string_io.reopen

    $string_io_logger ||= ActiveSupport::Logger.new($test_log_string_io)
    $string_io_logger.formatter = Rails.logger.formatter.dup
    $string_io_logger.level = :debug

    Rails.with(logger: $string_io_logger) do
      Sidekiq.default_configuration.with(logger: $string_io_logger) do
        # We can't just do ActiveRecord::Base.with(...) because `with` is an ActiveRecord method.
        Object.instance_method(:with).bind_call(ActiveRecord::Base, logger: $string_io_logger) do
          example.run
        end
      end
    end

    if example.exception
      # Prepare file name and directory
      timestamp = example.execution_result.started_at.in_time_zone.iso8601.tr(':', '-')
      description_as_brief_file_name =
        example.full_description.
          parameterize.
          last(50).
          sub(/\A[^[:alnum:]]+/, '')
      filename = "#{timestamp}-#{description_as_brief_file_name}.log"
      log_dir = Rails.root.join('log/failed_feature_specs')
      FileUtils.mkdir_p(log_dir)

      # Write log file
      File.write(log_dir.join(filename), $test_log_string_io.string)
    end
  end

  config.around(:each, :cache) do |spec|
    original_rails_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    spec.run
    Rails.cache = original_rails_cache
  end

  config.around(:each, :frozen_time) do |spec|
    freeze_time
    spec.run
    travel_back
  end

  config.define_derived_metadata(file_path: %r{/spec/controllers/api/}) do |metadata|
    # we leverage this metadata for the `config.before(:each, request_format: :json)` setting below
    metadata[:request_format] = :json
  end

  # begin prosopite >>>
  config.before(:each) do
    Prosopite.scan
  end

  config.after(:each) do
    Prosopite.finish
  end
  # <<< end prosopite

  # Permit some or all external requests (otherwise blocked by default).
  config.before do |example|
    metadata = example.metadata

    if metadata[:permit_all_external_requests]
      Capybara.current_driver = Cuprite::CustomDrivers::UNRESTRICTED_CUPRITE
    elsif (allowed_domains = metadata[:allowed_domains]).present?
      allowed_domains.each do |allowed_domain|
        page.driver.browser.url_allowlist << %r{\Ahttps://#{allowed_domain}/}
      end
    end
  end

  config.before(:each) do
    Rack::Attack.reset!
    $redis_pool.with { |conn| conn.call('flushdb', 'sync') }
    Sidekiq.redis { |conn| conn.call('flushdb', 'sync') }
  end

  config.before(:each, request_format: :json) do
    request.accept = 'application/json'
  end

  config.before(:each, :without_verifying_authorization) do
    allow(controller).to receive(:pundit_policy_authorized?).and_return(true)
  end

  config.before(:each, :prerendering_disabled) do
    activate_feature!(:disable_prerendering)
  end

  # NOTE: Using `Cuprite::BrowserLogger.javascript_errors` like this is not thread-safe.
  # For now, that's okay, because our tests only run in a single thread.
  config.around(:each, type: :feature) do |example|
    Cuprite::BrowserLogger.javascript_errors.clear
    Cuprite::BrowserLogger.javascript_logs.clear

    example.run

    expect(Cuprite::BrowserLogger.javascript_errors).to be_empty
    expect(Cuprite::BrowserLogger.javascript_logs).to be_empty
  end

  config.before(:each, :rails_env) do |example|
    expect(Rails).
      to receive(:env).
      at_least(:once).
      and_return(
        ActiveSupport::EnvironmentInquirer.new(
          example.metadata[:rails_env].to_s,
        ),
      )
  end

  config.around(:each, :wait_time) do |example|
    Capybara.using_wait_time(example.metadata[:wait_time]) do
      example.run
    end
  end

  config.before(:each, type: :controller) do
    # When executed, a Rails middleware will ensure that a `request_id` is set for each request.
    # However, middleware does not run for controller tests.
    # Therefore, here we stub a `request_id` in controller tests.
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(ActionController::TestRequest).
      to receive(:request_id).
      and_return(SecureRandom.uuid)

    allow_any_instance_of(ActionController::TestRequest).
      to receive(:headers).
      and_wrap_original do |original_headers_method|
        headers = original_headers_method.call
        headers['action_dispatch.request_id'] ||= SecureRandom.uuid
        headers
      end
    # rubocop:enable RSpec/AnyInstance
  end

  config.after(:each, type: :controller) do
    Devise.sign_out_all_scopes
  end

  config.around(:each, :rack_test_driver) do |spec|
    Capybara.current_driver = :rack_test
    spec.run
    Capybara.use_default_driver
  end

  config.around(:each, :inline_sidekiq) do |spec|
    Sidekiq::Testing.inline! { spec.run }
  end

  config.around(:each, :fake_aws_credentials) do |spec|
    original_credentials = Aws.config[:credentials]

    # rubocop:disable Rails/SaveBang
    Aws.config.update(
      credentials: Aws::Credentials.new(
        # these credentials are made up
        'BL3BI938XI837K0E32BU', # access_key_id
        'a8Bu8h03DD32mBUD8udod83FUFd73rlbUB9872OI', # secret_access_key
      ),
    )

    spec.run

    Aws.config.update(credentials: original_credentials)
    # rubocop:enable Rails/SaveBang
  end

  config.around(:each, :production_like_error_handling) do |spec|
    # https://github.com/rails/rails/pull/11289#issuecomment-118612393
    env_config = Rails.application.env_config
    original_show_exceptions = env_config['action_dispatch.show_exceptions']
    original_show_detailed_exceptions = env_config['action_dispatch.show_detailed_exceptions']
    env_config['action_dispatch.show_exceptions'] = :all
    env_config['action_dispatch.show_detailed_exceptions'] = false

    spec.run

    env_config['action_dispatch.show_exceptions'] = original_show_exceptions
    env_config['action_dispatch.show_detailed_exceptions'] = original_show_detailed_exceptions
  end

  config.around(:each, queue_adapter: :test) do |spec|
    original_active_job_queue_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
    spec.run
    ActiveJob::Base.queue_adapter = original_active_job_queue_adapter
  end

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with(:rspec) do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with(:rspec) do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata. When nothing
  # is tagged with `:focus`, all examples get run. RSpec also provides
  # aliases for `it`, `describe`, and `context` that include `:focus`
  # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  if !SpecHelper.is_ci?
    config.filter_run_when_matching(:focus)
  end

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  # config.example_status_persistence_file_path = 'spec/examples.txt'

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://rspec.info/blog/2012/06/rspecs-new-expectation-syntax/
  #   - http://www.teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/#zero-monkey-patching-mode
  config.disable_monkey_patching!

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  # config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand(config.seed)

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [Rails.root.join('spec/fixtures')]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework(:rspec)
    with.library(:rails)
  end
end

RSpec::Sidekiq.configure do |config|
  config.warn_when_jobs_not_processed_by_sidekiq = false
end
