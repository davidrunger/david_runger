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

class EnsureLatestChromedriverIsInstalled < Pallets::Task
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

    # we print the chromedriver version, to make sure that it was installed successfully and so that
    # we can view it for debugging, but we don't check it against a specific value, because it is
    # indeterminate / constantly changing (since we always use the latest Chrome and `chromedriver`)
    execute_system_command('chromedriver --version')
  end
end

class CheckVersions < Pallets::Task
  def run
    execute_system_command(<<~COMMAND)
      ruby --version && [ "$(ruby --version | cut -c1-11)" = 'ruby 2.7.0p' ]
    COMMAND
    execute_system_command(<<~COMMAND)
      bundler --version && [ "$(bundle --version | cut -c1-21)" = 'Bundler version 2.1.2' ]
    COMMAND
    execute_system_command(<<~COMMAND)
      node --version && [ "$(node --version)" = 'v12.13.1' ]
    COMMAND
    execute_system_command(<<~COMMAND)
      yarn --version && [ "$(yarn --version)" = '1.22.0' ]
    COMMAND
  end
end

class YarnInstall < Pallets::Task
  def run
    execute_system_command('yarn install')
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
      ./node_modules/.bin/eslint --max-warnings 0 --ext .js,.vue app/javascript/
    COMMAND
  end
end

class CompileJavaScript < Pallets::Task
  def run
    execute_system_command('bin/webpack --silent')
  end
end

class RunHtmlControllerTests < Pallets::Task
  def run
    # run all tests in `spec/controllers/` _except_ those in `spec/controllers/api/`
    execute_system_command(<<~COMMAND)
      bin/rspec
      $(ls -d spec/controllers/*/ | grep -v 'spec/controllers/api/' | tr '\\n' ' ')
      $(ls spec/controllers/*.rb)
      --format RSpec::Instafail --format progress --force-color
    COMMAND
  end
end

class RunFeatureTests < Pallets::Task
  def run
    # run all tests in `spec/features/` (wrapped by percy, if PERCY_TOKEN is present)
    execute_system_command(<<~COMMAND)
      #{'./node_modules/.bin/percy exec -- ' if ENV['PERCY_TOKEN'].present?}
      bin/rspec spec/features/
      --format RSpec::Instafail --format progress --force-color
    COMMAND
  end
end

class RunUnitTests < Pallets::Task
  def run
    # run all tests in `spec/` _except_ those in `spec/controllers/` that are _not_ in
    # `spec/controllers/api/` and those in `spec/features/`
    execute_system_command(<<~COMMAND)
      bin/rspec
      $(ls -d spec/*/ | grep --extended-regex -v 'spec/(controllers|features)/' | tr '\\n' ' ')
      spec/controllers/api/
      --format RSpec::Instafail --format progress --force-color
    COMMAND
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
    # Installation / Setup
    CheckVersions => nil,
    EnsureLatestChromedriverIsInstalled => nil,
    YarnInstall => nil,
    CompileJavaScript => YarnInstall,
    SetupDb => nil,
    BuildFixtures => SetupDb,

    # Checks
    RunStylelint => YarnInstall,
    # RunEslint depends on `CompileJavaScript` to write a `webpack.config.static.js` file
    RunEslint => CompileJavaScript,
    RunAnnotate => SetupDb,
    RunBrakeman => nil,
    RunDatabaseConsistency => SetupDb,
    RunImmigrant => SetupDb,
    RunRubocop => nil,
    RunUnitTests => BuildFixtures,
    RunHtmlControllerTests => [
      BuildFixtures,
      CompileJavaScript,
    ].freeze,
    RunFeatureTests => [
      BuildFixtures,
      CompileJavaScript,
      EnsureLatestChromedriverIsInstalled,
    ].freeze,

    # Exit depends on all other tasks completing that are actual checks (as opposed to setup steps)
    Exit => [
      CheckVersions,
      RunAnnotate,
      RunBrakeman,
      RunDatabaseConsistency,
      RunEslint,
      RunFeatureTests,
      RunHtmlControllerTests,
      RunImmigrant,
      RunRubocop,
      RunStylelint,
      RunUnitTests,
    ].freeze,
  }.freeze

  TRIMMABLE_CHECKS = {
    BuildFixtures => proc { running_locally? },
    RunAnnotate => proc { !db_schema_changed? },
    RunBrakeman => proc { !(haml_files_changed? || ruby_files_changed?) || running_locally? },
    RunDatabaseConsistency => proc { !db_schema_changed? },
    RunEslint => proc { !files_with_js_changed? },
    RunImmigrant => proc { !db_schema_changed? },
    RunRubocop => proc { !(ruby_files_changed? || files_mentioning_rubocop_changed?) },
    RunStylelint => proc { !files_with_css_changed? },
    SetupDb => proc { running_locally? },
    YarnInstall => proc { running_locally? },
  }.freeze

  class << self
    extend Memoist

    memoize \
    def db_schema_changed?
      files_changed.include?('db/schema.rb')
    end

    memoize \
    def diff
      command = <<~COMMAND.squish
        git log master..HEAD --full-diff --source --format="" --unified=0 -p .
          | grep -Ev "^(diff |index |--- a/|\\+\\+\\+ b/|@@ )"
      COMMAND
      `#{command}`
    end

    memoize \
    def diff_mentions_rubocop?
      diff.match?(%r{rubocop}i)
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
    def files_mentioning_rubocop_changed?
      files_changed.any? { |file| file.include?('rubocop') } # e.g. `.rubocop.yml`
    end

    memoize \
    def files_with_css_changed?
      (Dir['app/**/*.{css,scss,vue}'] & files_changed).any?
    end

    memoize \
    def files_with_js_changed?
      (Dir['app/javascript/**/*.{js,vue}'] & files_changed).any?
    end

    memoize \
    def haml_files_changed?
      (Dir['app/**/*.haml'] & files_changed).any?
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
    def running_locally?
      !ENV.key?('TRAVIS')
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
