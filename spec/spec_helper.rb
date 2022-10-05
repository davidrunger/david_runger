# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'factory_bot_rails'
require 'webmock'
require 'webmock/rspec'
require 'pundit/rspec'
is_ci = (ENV.fetch('CI', nil) == 'true')
use_headful_chrome = ENV.fetch('HEADFUL_CHROME', nil).present?
require 'simplecov'
if is_ci
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
  Codecov.pass_ci_if_error = true
elsif (executed_spec_files = ARGV.grep(%r{\Aspec/}).presence)
  require_relative '../tools/simplecov/formatter/terminal.rb'
  SimpleCov::Formatter::Terminal.executed_spec_files = executed_spec_files
  SimpleCov.formatter = SimpleCov::Formatter::Terminal
end
SimpleCov.start do
  add_filter(%r{^/spec/})
  enable_coverage(:branch)
end
require File.expand_path('../config/environment', __dir__)
require Rails.root.join('spec/support/fixture_builder.rb').to_s
Dir['spec/support/**/*.rb'].each { |file| require Rails.root.join(file) }
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/email/rspec'
require 'capybara-screenshot/rspec' unless use_headful_chrome
require 'active_support/cache/mem_cache_store'
require 'sidekiq/testing'
require 'mail'
require 'percy/capybara'
require 'super_diff/rspec-rails'

# w/o this, Sidekiq's `logger` prints to STDOUT (bad); with this, it prints to `log/test.log` (good)
Sidekiq.default_configuration.logger = Rails.logger

WebMock.enable!
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: 'david-runger-test-uploads.s3.amazonaws.com', # upload feature test failure screenshots
  net_http_connect_on_start: true,
)

OmniAuth.config.test_mode = true

Capybara.register_driver(:chrome_headless) do |app|
  options = Selenium::WebDriver::Chrome::Options.new(args: %w[no-sandbox headless disable-gpu])
  Capybara::Selenium::Driver.new(app, browser: :chrome, capabilities: [options])
end
Capybara.register_driver(:chrome_headful) do |app|
  options = Selenium::WebDriver::Chrome::Options.new(args: %w[no-sandbox disable-gpu])
  Capybara::Selenium::Driver.new(app, browser: :chrome, capabilities: [options])
end
unless use_headful_chrome
  Capybara::Screenshot.register_driver(:chrome_headless) do |driver, path|
    driver.browser.save_screenshot(path)
  end
end
if is_ci
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
browser_driver = use_headful_chrome ? :chrome_headful : :chrome_headless
Capybara.default_driver = browser_driver
Capybara.javascript_driver = browser_driver
# allow loading JS & CSS assets via `save_and_open_page` when running `rails s`
Capybara.asset_host = 'http://localhost:3000'
Capybara.server = :puma, { Silent: true }
Capybara.default_normalize_ws = true
# this matches setting in config/environments/test.rb
Capybara.server_port = 3001
Capybara.app_host = 'http://localhost:3001'

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
  config.include(Devise::Test::ControllerHelpers, type: :controller)
  config.include(Devise::Test::IntegrationHelpers, type: :feature)
  config.include(Monkeypatches::MakeAllRequestsAsJson, request_format: :json)
  config.include(ActionCable::TestHelper, :action_cable_test_adapter)
  config.include(ActionMailbox::TestHelper, type: :mailbox)
  config.include(ActionMailbox::TestHelper, type: :mailer)
  config.include(MailSpecHelpers, type: :mailbox)
  config.include(MailSpecHelpers, type: :mailer)

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

  if Bullet.enable?
    config.before(:each) do
      Bullet.start_request
    end

    config.after(:each) do
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end

  config.before(:each) do
    Rack::Attack.reset!
    RedisConfig.clear!
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
      and_wrap_original do |request|
        headers = request.call
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
    env_config['action_dispatch.show_exceptions'] = true
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
  config.filter_run_when_matching(:focus)

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
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

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
