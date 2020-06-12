# frozen_string_literal: true

module Test ; end
module Test::Tasks ; end

require_relative '../../config/application.rb'
require 'English'
require 'benchmark'
require File.join(File.dirname(__FILE__), 'global_methods.rb')
Dir[File.join(File.dirname(__FILE__), 'tasks', '*.rb')].each { require _1 }

Rails.application.load_tasks

class Test::Runner < Pallets::Workflow
  DEPENDENCY_MAP = {
    # Installation / Setup
    Test::Tasks::CheckVersions => nil,
    Test::Tasks::EnsureLatestChromedriverIsInstalled => nil,
    Test::Tasks::YarnInstall => nil,
    Test::Tasks::CompileJavaScript => Test::Tasks::YarnInstall,
    Test::Tasks::SetupDb => nil,
    Test::Tasks::BuildFixtures => Test::Tasks::SetupDb,

    # Checks
    Test::Tasks::RunStylelint => Test::Tasks::YarnInstall,
    # RunEslint depends on `CompileJavaScript` to write a `webpack.config.static.js` file
    Test::Tasks::RunEslint => Test::Tasks::CompileJavaScript,
    Test::Tasks::RunAnnotate => Test::Tasks::SetupDb,
    Test::Tasks::RunBrakeman => nil,
    Test::Tasks::RunDatabaseConsistency => Test::Tasks::SetupDb,
    Test::Tasks::RunImmigrant => Test::Tasks::SetupDb,
    Test::Tasks::RunRubocop => nil,
    Test::Tasks::RunUnitTests => Test::Tasks::BuildFixtures,
    Test::Tasks::RunHtmlControllerTests => [
      Test::Tasks::BuildFixtures,
      Test::Tasks::CompileJavaScript,
    ].freeze,
    Test::Tasks::RunFeatureTests => [
      Test::Tasks::BuildFixtures,
      Test::Tasks::CompileJavaScript,
      Test::Tasks::EnsureLatestChromedriverIsInstalled,
    ].freeze,

    # Exit depends on all other tasks completing that are actual checks (as opposed to setup steps)
    Test::Tasks::Exit => [
      Test::Tasks::CheckVersions,
      Test::Tasks::RunAnnotate,
      Test::Tasks::RunBrakeman,
      Test::Tasks::RunDatabaseConsistency,
      Test::Tasks::RunEslint,
      Test::Tasks::RunFeatureTests,
      Test::Tasks::RunHtmlControllerTests,
      Test::Tasks::RunImmigrant,
      Test::Tasks::RunRubocop,
      Test::Tasks::RunStylelint,
      Test::Tasks::RunUnitTests,
    ].freeze,
  }.freeze

  TRIMMABLE_CHECKS = {
    Test::Tasks::BuildFixtures => proc { running_locally? },
    Test::Tasks::RunAnnotate => proc { !db_schema_changed? },
    Test::Tasks::RunBrakeman => proc {
      !(haml_files_changed? || ruby_files_changed?) || running_locally?
    },
    Test::Tasks::RunDatabaseConsistency => proc { !db_schema_changed? },
    Test::Tasks::RunEslint => proc { !files_with_js_changed? },
    Test::Tasks::RunImmigrant => proc { !db_schema_changed? },
    Test::Tasks::RunRubocop => proc {
      !(ruby_files_changed? || files_mentioning_rubocop_changed?)
    },
    Test::Tasks::RunStylelint => proc { !files_with_css_changed? },
    Test::Tasks::SetupDb => proc { running_locally? },
    Test::Tasks::YarnInstall => proc { running_locally? },
  }.freeze

  class << self
    extend Memoist

    memoize \
    def db_schema_changed?
      files_changed.include?('db/schema.rb')
    end

    memoize \
    def diff
      `git log master..HEAD --full-diff --source --format="" --unified=0 -p . \
        | grep -Ev "^(diff |index |--- a/|\\+\\+\\+ b/|@@ )"`
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
      ruby_files =
        Dir['*.rb'] +
        Dir.glob('*').select { File.directory?(_1) }.map do |directory|
          Dir["#{directory}/**/*.rb"]
        end.flatten
      (ruby_files & files_changed).any?
    end
  end

  target_tasks = [Test::Tasks::Exit]
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
  ap('NOT running these tasks:')
  ap((DEPENDENCY_MAP.keys - true_requirements).map(&:name).sort)

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
