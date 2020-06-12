# frozen_string_literal: true

class Test::RequirementsResolver
  extend Memoist
  include DiffHelpers

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
      new_tentative_requirements = tentative_requirements
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
    instance_eval(&(CHECK_CAN_BE_SKIPPED_CONDITIONS[task] || proc { false }))
  end

  def tasks_and_dependencies(target_tasks, known_dependencies: [], skippable_requirements: [])
    new_dependencies =
      DEPENDENCY_MAP.values_at(*target_tasks).
        flatten.reject(&:nil?) - known_dependencies - skippable_requirements

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
    !ENV.key?('TRAVIS')
  end
end
