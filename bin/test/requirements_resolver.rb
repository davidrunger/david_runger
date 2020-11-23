# frozen_string_literal: true

class Test::RequirementsResolver
  extend Memoist
  include DiffHelpers

  class << self
    extend Memoist

    # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    memoize \
    def dependency_map
      base_dependency_map = {
        # Installation / Setup
        Test::Tasks::EnsureLatestChromedriver => nil,
        Test::Tasks::YarnInstall => nil,
        Test::Tasks::CheckVersions => nil,
        Test::Tasks::CompileJavaScript => Test::Tasks::YarnInstall,
        Test::Tasks::SetupDb => nil,
        Test::Tasks::BuildFixtures => Test::Tasks::SetupDb,
        Test::Tasks::CreateDbCopies => Test::Tasks::BuildFixtures,

        # Checks
        Test::Tasks::RunStylelint => Test::Tasks::YarnInstall,
        # RunEslint depends on `CompileJavaScript` to write a `webpack.config.static.js` file
        Test::Tasks::RunEslint => Test::Tasks::CompileJavaScript,
        Test::Tasks::RunAnnotate => Test::Tasks::SetupDb,
        Test::Tasks::RunBrakeman => nil,
        Test::Tasks::RunDatabaseConsistency => Test::Tasks::SetupDb,
        Test::Tasks::RunImmigrant => Test::Tasks::SetupDb,
        Test::Tasks::RunRubocop => nil,
        Test::Tasks::RunUnitTests => Test::Tasks::CreateDbCopies,
        Test::Tasks::RunApiControllerTests => Test::Tasks::CreateDbCopies,
        Test::Tasks::RunHtmlControllerTests => [
          Test::Tasks::CreateDbCopies,
          Test::Tasks::CompileJavaScript,
        ],
        Test::Tasks::RunFeatureTests => [
          Test::Tasks::CreateDbCopies,
          Test::Tasks::CompileJavaScript,
          Test::Tasks::EnsureLatestChromedriver,
        ],

        # Exit depends on all tasks completing that are actual checks (as opposed to setup steps)
        Test::Tasks::Exit => [
          Test::Tasks::CheckVersions,
          Test::Tasks::RunAnnotate,
          Test::Tasks::RunBrakeman,
          Test::Tasks::RunDatabaseConsistency,
          Test::Tasks::RunEslint,
          Test::Tasks::RunFeatureTests,
          Test::Tasks::RunApiControllerTests,
          Test::Tasks::RunHtmlControllerTests,
          Test::Tasks::RunImmigrant,
          Test::Tasks::RunRubocop,
          Test::Tasks::RunStylelint,
          Test::Tasks::RunUnitTests,
        ],
      }

      if run_defaults?
        # change nothing
      elsif run_all?
        all_non_exit_tasks = base_dependency_map.keys.reject { _1 == Test::Tasks::Exit }
        base_dependency_map[Test::Tasks::Exit] = all_non_exit_tasks
      else
        validate_task_config_groups!

        if targets.any?
          base_dependency_map[Test::Tasks::Exit] = targets
        end

        forces.each do |force|
          if !force.in?(base_dependency_map[Test::Tasks::Exit])
            base_dependency_map[Test::Tasks::Exit] << force
          end
        end

        skips.each do |skip|
          base_dependency_map.reject! { |key, _value| key == skip }
          base_dependency_map.transform_values! do |value|
            if value.nil?
              value
            elsif Array(value).include?(skip)
              Array(value).reject { _1 == skip }
            else
              value
            end
          end
        end
      end

      base_dependency_map
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

    def verify?
      global_config['verify']
    end

    def run_defaults?
      global_config['run_defaults']
    end

    def run_all?
      global_config['run_all']
    end

    memoize \
    def config
      YAML.load_file('bin/test/.tests.yml') rescue Hash.new { |hash, key| hash[key] = {} }
    end

    def forces
      (task_config_groups['force'] || []).map { "Test::Tasks::#{_1}".constantize }
    end

    def global_config
      config['global']
    end

    def skips
      (task_config_groups['skip'] || []).map { "Test::Tasks::#{_1}".constantize }
    end

    def targets
      (task_config_groups['target'] || []).map { "Test::Tasks::#{_1}".constantize }
    end

    def task_config
      config['tasks'].transform_values { _1 || 'default' }
    end

    memoize \
    def task_config_groups
      task_config.group_by { |_key, value| value }.transform_values { _1.map(&:first) }
    end

    def validate_task_config_groups!
      task_config_options = %w[
        default
        force
        skip
        target
      ]

      unexpected_task_options = task_config_groups.keys - task_config_options
      if unexpected_task_options.any?
        raise("Bad task_config! Unexpected options #{unexpected_task_options}.")
      end
    end
  end

  CHECK_CAN_BE_SKIPPED_CONDITIONS = {
    Test::Tasks::BuildFixtures => proc { running_locally? },
    Test::Tasks::RunAnnotate => proc { !db_schema_changed? },
    Test::Tasks::RunBrakeman => proc {
      !(haml_files_changed? || ruby_files_changed?) || running_locally?
    },
    Test::Tasks::RunDatabaseConsistency => proc { !db_schema_changed? },
    Test::Tasks::RunEslint => proc { !files_with_js_changed? },
    Test::Tasks::RunImmigrant => proc { !db_schema_changed? },
    Test::Tasks::RunRubocop => proc {
      !(ruby_files_changed? || rubocop_files_changed? || diff_mentions_rubocop?)
    },
    Test::Tasks::RunStylelint => proc { !files_with_css_changed? },
    Test::Tasks::SetupDb => proc { running_locally? },
    Test::Tasks::YarnInstall => proc { running_locally? },
  }.freeze

  def required_tasks
    target_tasks = [Test::Tasks::Exit]
    true_requirements = target_tasks
    # loop up to 10 times to iteratively trim down the necessary dependencies
    iterations = 10
    iterations.times do |index|
      true_requirements_at_start = true_requirements

      tentative_requirements = tasks_and_dependencies(target_tasks)
      new_tentative_requirements = tentative_requirements.dup
      skippable_requirements = []
      tentative_requirements.each do |task|
        if can_skip?(task)
          skippable_requirements << task
          new_tentative_requirements.delete(task)
        end
      end
      true_requirements = new_tentative_requirements
      true_requirements = tasks_and_dependencies(
        true_requirements,
        skippable_requirements: skippable_requirements,
      )

      if true_requirements_at_start.map(&:name).sort == true_requirements.map(&:name).sort
        break
      elsif index == iterations - 1
        raise('We reached the iteration limit for trimming the required tasks!')
      end
    end

    true_requirements
  end

  private

  def can_skip?(task)
    return false if self.class.run_all?

    if !self.class.run_defaults?
      return false if self.class.forces.include?(task)
      return true if self.class.skips.include?(task)
      return false if self.class.targets.include?(task)
    end

    instance_eval(&(CHECK_CAN_BE_SKIPPED_CONDITIONS[task] || proc { false }))
  end

  def tasks_and_dependencies(target_tasks, known_dependencies: [], skippable_requirements: [])
    new_dependencies =
      self.class.dependency_map.values_at(*(target_tasks - self.class.skips)).
        flatten.reject(&:nil?) - known_dependencies - skippable_requirements
    new_dependencies.reject! { can_skip?(_1) }

    if new_dependencies.empty?
      target_tasks
    else
      total_dependencies = target_tasks + new_dependencies
      (target_tasks + tasks_and_dependencies(
        new_dependencies,
        known_dependencies: total_dependencies,
        skippable_requirements: skippable_requirements,
      )).flatten.uniq
    end
  end

  memoize \
  def running_locally?
    !ENV.key?('CI')
  end
end
