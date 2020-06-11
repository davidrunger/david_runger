#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/application.rb'

require 'benchmark'
require 'English'

Rails.application.load_tasks
Rails.application.eager_load!

class ExitOnFailureMiddleware
  def self.call(_worker, _job, _context)
    yield
  rescue => error
    puts("Error occurred ('exited with 1') in Pallets runner: #{error.inspect}".red)
    puts(error.backtrace)
    exit(1)
  end
end

Pallets.configure do |c|
  c.concurrency = 3
  c.backend = :redis
  c.backend_args = { url: 'redis://127.0.0.1:6379/8' } # use redis db #8 (to avoid conflicts)
  c.serializer = :msgpack
  c.job_timeout = 120 # allow 2 minutes for each task to complete
  c.max_failures = 0
  c.logger = Logger.new(STDOUT)
  c.middleware << ExitOnFailureMiddleware
end

def execute_system_command(command)
  command = command.squish
  puts("Running system command '#{command}' ...")
  time = Benchmark.measure { system(command) }.real
  exit_code = $CHILD_STATUS.exitstatus
  if exit_code == 0
    puts("'#{command}' succeeded (exited with #{exit_code}, took #{time.round(3)}).".green)
  else
    OrchestrateTests.exit_code = exit_code if OrchestrateTests.exit_code == 0
    puts("'#{command}' failed (exited with #{exit_code}, took #{time.round(3)}).".red)
  end
end

def execute_rake_task(task_name, *args)
  puts("Running rake task '#{task_name}' with args #{args.inspect} ...")
  time = nil
  begin
    time = Benchmark.measure { Rake::Task[task_name].invoke(*args) }.real
  rescue SystemExit => error
    puts("'#{task_name}' failed ('exited with 1', raised #{error.inspect}).".red)
    raise # this will exit the program if it's a `SystemExit` exception
  rescue => error
    puts("'#{task_name}' failed ('exited with 1', raised #{error.inspect}).".red)
    OrchestrateTests.exit_code = 1 if OrchestrateTests.exit_code == 0
  else
    puts("'#{task_name}' succeeded (took #{time.round(3)}).".green)
  end
end

class AddYarnToPath < Pallets::Task
  def run
    execute_system_command('export PATH="$HOME/.yarn/bin:$PATH"')
  end
end

class InstallChromedriver < Pallets::Task
  def run
    latest_release = `wget -qO- https://chromedriver.storage.googleapis.com/LATEST_RELEASE`
    if (`chromedriver --version` rescue '').include?(" #{latest_release} ")
      puts("The latest chromedriver release (#{latest_release}) is already installed.")
    else
      filename =
        `echo $OSTYPE`.match?(%r{darwin}) ? 'chromedriver_mac64.zip' : 'chromedriver_linux64.zip'
      execute_system_command(<<~COMMAND)
        curl -o $(pwd)/tmp/chromedriver.zip
        https://chromedriver.storage.googleapis.com/#{latest_release}/#{filename}
      COMMAND
      execute_system_command('unzip -d "$HOME/bin/" $(pwd)/tmp/chromedriver.zip')
    end
  end
end

class CheckRubyVersion < Pallets::Task
  def run
    execute_system_command(<<~COMMAND)
      ruby --version && [ "$(ruby --version | cut -c1-11)" = 'ruby 2.7.0p' ]
    COMMAND
  end
end

class CheckBundlerVersion < Pallets::Task
  def run
    execute_system_command(<<~COMMAND)
      bundler --version && [ "$(bundle --version | cut -c1-21)" = 'Bundler version 2.1.2' ]
    COMMAND
  end
end

class CheckNodeVersion < Pallets::Task
  def run
    execute_system_command(<<~COMMAND)
      node --version && [ "$(node --version)" = 'v12.13.1' ]
    COMMAND
  end
end

class CheckYarnVersion < Pallets::Task
  def run
    execute_system_command(<<~COMMAND)
      yarn --version && [ "$(yarn --version)" = '1.22.0' ]
    COMMAND
  end
end

class PrintChromedriverVersion < Pallets::Task
  def run
    # print chromedriver version, but don't check it, because it changes
    execute_system_command('chromedriver --version')
  end
end

class YarnInstall < Pallets::Task
  def run
    execute_system_command('yarn install')
  end
end

class SetupJs < Pallets::Task
  def run
    # boot test server
    execute_system_command('ruby -run -ehttpd public -p8080 > /dev/null 2>&1 &')
    # setup tests
    execute_system_command('bin/setup-mocha-tests >/dev/null 2>&1')
    # compile
    execute_system_command('bin/webpack --silent')
  end
end

class RunRubocop < Pallets::Task
  def run
    execute_system_command(<<~COMMAND)
      bin/rubocop $(git ls-tree -r HEAD --name-only) --force-exclusion --format clang
    COMMAND
  end
end

class RunBrakeman < Pallets::Task
  def run
    execute_system_command('bin/brakeman --quiet')
  end
end

class RunStylelint < Pallets::Task
  def run
    execute_system_command('./node_modules/.bin/stylelint app/**/*.{css,scss,vue} --max-warnings 0')
  end
end

class SetupDb < Pallets::Task
  def run
    execute_rake_task('db:create')
    execute_rake_task('db:environment:set', 'RAILS_ENV=test')
    execute_rake_task('db:schema:load')
  end
end

class RunDatabaseConsistency < Pallets::Task
  def run
    execute_system_command('bin/database_consistency')
  end
end

class RunImmigrant < Pallets::Task
  def run
    execute_rake_task('immigrant:check_keys')
  end
end

class RunAnnotate < Pallets::Task
  def run
    execute_system_command(<<~COMMAND)
      bin/annotate --models --show-indexes --sort --exclude fixtures,tests && git diff --exit-code
    COMMAND
  end
end

class BuildFixtures < Pallets::Task
  def run
    execute_rake_task('spec:fixture_builder:rebuild')
  end
end

class RunEslint < Pallets::Task
  def run
    execute_system_command(<<~COMMAND)
      ./node_modules/.bin/eslint --max-warnings 0 --ext .js,.vue app/javascript/ spec/javascript/
    COMMAND
  end
end

class RunJsSpecs < Pallets::Task
  def run
    # run the tests
    execute_system_command('yarn run test')
    # kill JS unit test server (if running)
    execute_system_command(<<~COMMAND)
      ps -ax | egrep 'ruby.*httpd' | egrep -v grep | awk '{print $1}' | xargs kill
    COMMAND
  end
end

class ConfigureWebpackerForRubyTests < Pallets::Task
  def run
    execute_rake_task(
      'assets:copy_webpacker_settings',
      'production',
      'test',
      'cache_manifest compile extract_css source_path',
    )
  end
end

class CompileJavaScriptForRubyTests < Pallets::Task
  def run
    execute_system_command('bin/webpack --silent')
  end
end

class RunRubySpecs < Pallets::Task
  def run
    execute_system_command(<<~COMMAND)
      #{'./node_modules/.bin/percy exec -- ' if ENV['PERCY_TOKEN'].present?}
      bin/rspec --format documentation
    COMMAND
  ensure
    execute_system_command('git checkout config/webpacker.yml')
  end
end

class Exit < Pallets::Task
  def run
    puts("Exiting with code #{OrchestrateTests.exit_code}")
    exit(OrchestrateTests.exit_code)
  end
end

class OrchestrateTests < Pallets::Workflow
  DEPENDENCY_MAP = {
    # Installation
    InstallChromedriver => nil,
    PrintChromedriverVersion => InstallChromedriver,
    CheckRubyVersion => nil,
    CheckBundlerVersion => nil,
    CheckNodeVersion => nil,
    AddYarnToPath => nil,
    CheckYarnVersion => AddYarnToPath,
    YarnInstall => AddYarnToPath,

    # JavaScript checks
    RunStylelint => YarnInstall,
    SetupJs => YarnInstall,
    # RunEslint depends on SetupJs to write webpack.config.static.js
    RunEslint => SetupJs,
    RunJsSpecs => SetupJs,

    # Ruby checks
    RunRubocop => nil,
    RunBrakeman => nil,
    SetupDb => nil,
    RunDatabaseConsistency => SetupDb,
    RunImmigrant => SetupDb,
    RunAnnotate => SetupDb,
    BuildFixtures => SetupDb,
    # this config change depends on SetupJs completing in order to avoid webpacker config conflict
    ConfigureWebpackerForRubyTests => SetupJs,
    CompileJavaScriptForRubyTests => [
      ConfigureWebpackerForRubyTests,
      YarnInstall,
    ].freeze,
    RunRubySpecs => [
      BuildFixtures,
      CompileJavaScriptForRubyTests,
      ConfigureWebpackerForRubyTests,
    ].freeze,

    # Exit depends on all other tasks completing that are actual checks (as opposed to setup steps)
    Exit => [
      CheckRubyVersion,
      CheckBundlerVersion,
      CheckNodeVersion,
      CheckYarnVersion,
      PrintChromedriverVersion,
      RunAnnotate,
      RunBrakeman,
      RunDatabaseConsistency,
      RunEslint,
      RunImmigrant,
      RunJsSpecs,
      RunRubocop,
      RunRubySpecs,
      RunStylelint,
    ].freeze,
  }.freeze

  TRIMMABLE_CHECKS = {
    AddYarnToPath => proc { !ENV.key?('TRAVIS') },
    YarnInstall => proc { !ENV.key?('TRAVIS') },
    RunAnnotate => proc { !OrchestrateTests.db_schema_changed? },
    RunBrakeman => proc do
      haml_or_ruby_files_changed =
        OrchestrateTests.haml_files_changed? || OrchestrateTests.ruby_files_changed?
      !haml_or_ruby_files_changed
    end,
    RunDatabaseConsistency => proc { !OrchestrateTests.db_schema_changed? },
    RunEslint => proc { !OrchestrateTests.files_with_js_changed? },
    RunImmigrant => proc { !OrchestrateTests.db_schema_changed? },
    RunJsSpecs => proc { !OrchestrateTests.files_with_js_changed? },
    RunRubocop => proc { !ruby_files_changed? },
    RunStylelint => proc { !OrchestrateTests.files_with_css_changed? },
    SetupJs => proc do |tentative_list|
      true_dependents = [RunEslint, RunJsSpecs]
      (tentative_list & true_dependents).empty?
    end,
  }.freeze

  class << self
    extend Memoist

    memoize \
    def db_schema_changed?
      files_changed.include?('db/schema.rb')
    end

    memoize \
    def files_changed
      if !system('git log -1 --pretty="%H" master > /dev/null 2>&1')
        puts('`master` branch is not present; fetching it now...')
        `git fetch origin master:master --depth=1`
        puts('Done fetching origin master branch.')
      end

      `git diff --name-only $(git merge-base HEAD master)`.rstrip.split("\n")
    end

    memoize \
    def files_with_css_changed?
      (Dir['app/**/*.{css,scss,vue}'] & files_changed).any?
    end

    memoize \
    def files_with_js_changed?
      (
        (Dir['app/javascript/**/*.{js,vue}'] + Dir['spec/javascript/**/*.{js,vue}']) &
          files_changed
      ).any?
    end

    def required_tasks(target_tasks, known_dependencies: [], trimmable_requirements: [])
      new_dependencies =
        DEPENDENCY_MAP.values_at(*target_tasks).
          flatten.reject(&:nil?) - known_dependencies - trimmable_requirements

      if new_dependencies.empty?
        target_tasks
      else
        total_dependencies = target_tasks + new_dependencies
        (target_tasks + required_tasks(
          new_dependencies,
          known_dependencies: total_dependencies,
          trimmable_requirements: trimmable_requirements,
        )).flatten.uniq
      end
    end

    memoize \
    def haml_files_changed?
      (Dir['app/**/*.haml'] & files_changed).any?
    end

    memoize \
    def ruby_files_changed?
      (FileList['**/*.rb'].exclude(%r{\Avendor/}).to_a & files_changed).any?
    end
  end

  target_tasks = [Exit]
  true_requirements = target_tasks
  # loop up to 10 times to iteratively trim down the necessary dependencies
  iterations = 10
  iterations.times do |index|
    true_requirements_at_start = true_requirements

    tentative_requirements = required_tasks(target_tasks)
    new_tentative_requirements = tentative_requirements
    trimmable_requirements = []
    tentative_requirements.sort_by { |task| TRIMMABLE_CHECKS.keys.index(task) || -1 }.each do |task|
      if TRIMMABLE_CHECKS[task]&.call(new_tentative_requirements)
        trimmable_requirements << task
        new_tentative_requirements.delete(task)
      end
    end
    true_requirements = new_tentative_requirements
    true_requirements = required_tasks(
      true_requirements,
      trimmable_requirements: trimmable_requirements,
    )

    if true_requirements_at_start.map(&:name).sort == true_requirements.map(&:name).sort
      break
    elsif index == iterations - 1
      raise('We reached the iteration limit for trimming the required tasks!')
    end
  end

  ap('Running these tasks:')
  ap(true_requirements.map(&:name).sort)

  DEPENDENCY_MAP.slice(*true_requirements).each do |task, prerequisites|
    if Array(prerequisites).reject(&:nil?).empty?
      task(task)
    else
      task(task => Array(prerequisites) & true_requirements)
    end
  end

  class << self
    attr_accessor :exit_code
  end

  self.exit_code = 0
end

OrchestrateTests.new.run
