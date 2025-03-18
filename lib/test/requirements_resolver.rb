class Test::RequirementsResolver
  prepend Memoization
  include DiffHelpers

  class << self
    prepend Memoization

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    memoize \
    def dependency_map
      base_dependency_map = {
        # NB: Tasks that are better to run earlier are listed first.

        # Installation / Setup
        Test::Tasks::PnpmInstall => nil,
        Test::Tasks::BuildRouteHelpers => Test::Tasks::PnpmInstall,
        Test::Tasks::CompileAdminJavaScript => [
          Test::Tasks::BuildRouteHelpers,
          Test::Tasks::ConvertSchemasToTs,
        ],
        Test::Tasks::CompileUserJavaScript => [
          Test::Tasks::BuildRouteHelpers,
          Test::Tasks::ConvertSchemasToTs,
        ],
        Test::Tasks::SetupDb => nil,
        Test::Tasks::BuildFixtures => Test::Tasks::SetupDb,
        Test::Tasks::CreateDbCopies => Test::Tasks::BuildFixtures,
        Test::Tasks::DivideFeatureSpecs => nil,
        Test::Tasks::StartPercy => Test::Tasks::PnpmInstall,

        # Checks
        Test::Tasks::CheckVersions => nil,
        Test::Tasks::CheckTypescript => [
          Test::Tasks::BuildRouteHelpers,
          Test::Tasks::ConvertSchemasToTs,
          Test::Tasks::RunTypelizer,
        ],
        Test::Tasks::RunPrettier => [
          Test::Tasks::PnpmInstall,
          Test::Tasks::ConvertSchemasToTs,
        ],
        Test::Tasks::RunStylelint => Test::Tasks::PnpmInstall,
        Test::Tasks::RunEslint => [
          Test::Tasks::PnpmInstall,
          Test::Tasks::ConvertSchemasToTs,
        ],
        Test::Tasks::RunTsd => Test::Tasks::PnpmInstall,
        Test::Tasks::RunVitest => Test::Tasks::PnpmInstall,
        Test::Tasks::RunAnnotate => Test::Tasks::CreateDbCopies,
        Test::Tasks::RunTypelizer => [
          Test::Tasks::ConvertSchemasToTs,
          Test::Tasks::CreateDbCopies,
        ],
        Test::Tasks::ConvertSchemasToTs => [
          Test::Tasks::PnpmInstall,
          Test::Tasks::SetupDb,
        ],
        Test::Tasks::RunBrakeman => nil,
        Test::Tasks::RunDatabaseConsistency => Test::Tasks::CreateDbCopies,
        Test::Tasks::RunImmigrant => Test::Tasks::CreateDbCopies,
        Test::Tasks::RunRubocop => nil,
        Test::Tasks::RunUnitTests => Test::Tasks::CreateDbCopies,
        Test::Tasks::RunToolsTests => Test::Tasks::RunUnitTests,
        Test::Tasks::RunApiControllerTests => Test::Tasks::CreateDbCopies,
        Test::Tasks::RunFileSizeChecks => Test::Tasks::CompileUserJavaScript,
        Test::Tasks::RunFeatureTestsA => [
          Test::Tasks::DivideFeatureSpecs,
          Test::Tasks::CreateDbCopies,
          Test::Tasks::CompileAdminJavaScript,
          Test::Tasks::CompileUserJavaScript,
          Test::Tasks::StartPercy,
        ],
        Test::Tasks::RunFeatureTestsB => [
          Test::Tasks::DivideFeatureSpecs,
          Test::Tasks::CreateDbCopies,
          Test::Tasks::CompileAdminJavaScript,
          Test::Tasks::CompileUserJavaScript,
          Test::Tasks::StartPercy,
          Test::Tasks::RunApiControllerTests,
        ],
        Test::Tasks::RunFeatureTestsC => [
          Test::Tasks::DivideFeatureSpecs,
          Test::Tasks::CreateDbCopies,
          Test::Tasks::CompileAdminJavaScript,
          Test::Tasks::CompileUserJavaScript,
          Test::Tasks::StartPercy,
        ],
        Test::Tasks::FeatureTestsCanStart => [
          Test::Tasks::CompileAdminJavaScript,
          Test::Tasks::CompileUserJavaScript,
          Test::Tasks::CreateDbCopies,
          Test::Tasks::DivideFeatureSpecs,
          Test::Tasks::RunApiControllerTests,
          Test::Tasks::StartPercy,
        ],
        Test::Tasks::RunHtmlControllerTests => [
          Test::Tasks::CreateDbCopies,
          Test::Tasks::CompileAdminJavaScript,
          Test::Tasks::CompileUserJavaScript,
          Test::Tasks::FeatureTestsCanStart,
        ],

        # Necessary processes.
        Test::Tasks::StopPercy => [
          Test::Tasks::RunFeatureTestsA,
          Test::Tasks::RunFeatureTestsB,
          Test::Tasks::RunFeatureTestsC,
        ],
        Test::Tasks::UploadViteAssets => [
          Test::Tasks::CompileAdminJavaScript,
          Test::Tasks::CompileUserJavaScript,
          # UploadViteAssets doesn't really depend on RunHtmlControllerTests,
          # but it's better for the timing of steps if it waits until after it.
          Test::Tasks::RunHtmlControllerTests,
        ],

        # Exit depends on all tasks completing that are actual checks (as opposed to setup steps).
        Test::Tasks::Exit => [
          Test::Tasks::CheckTypescript,
          Test::Tasks::CheckVersions,
          Test::Tasks::ConvertSchemasToTs,
          Test::Tasks::RunAnnotate,
          Test::Tasks::RunApiControllerTests,
          Test::Tasks::RunBrakeman,
          Test::Tasks::RunDatabaseConsistency,
          Test::Tasks::RunEslint,
          Test::Tasks::RunFeatureTestsA,
          Test::Tasks::RunFeatureTestsB,
          Test::Tasks::RunFeatureTestsC,
          Test::Tasks::RunFileSizeChecks,
          Test::Tasks::RunHtmlControllerTests,
          Test::Tasks::RunImmigrant,
          Test::Tasks::RunPrettier,
          Test::Tasks::RunRubocop,
          Test::Tasks::RunStylelint,
          Test::Tasks::RunToolsTests,
          Test::Tasks::RunTsd,
          Test::Tasks::RunTypelizer,
          Test::Tasks::RunUnitTests,
          Test::Tasks::RunVitest,
          Test::Tasks::StopPercy,
          Test::Tasks::UploadViteAssets,
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
          next if force == Test::Tasks::Exit # don't allow Exit to be a dependency of itself

          if !force.in?(base_dependency_map[Test::Tasks::Exit])
            base_dependency_map[Test::Tasks::Exit] << force
          end
        end

        skips.each do |skip|
          base_dependency_map.reject! { |key, _value| key == skip }
          base_dependency_map.transform_values! do |value|
            # rubocop:disable Lint/DuplicateBranch
            if value.nil?
              value
            elsif Array(value).include?(skip)
              Array(value).reject { _1 == skip }
            else
              value
            end
            # rubocop:enable Lint/DuplicateBranch
          end
        end
      end

      base_dependency_map
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/MethodLength

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
      YAML.load_file('lib/test/.tests.yml') rescue Hash.new { |hash, key| hash[key] = {} }
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
      task_config_options = %w[default force skip target]

      unexpected_task_options = task_config_groups.keys - task_config_options
      if unexpected_task_options.any?
        raise("Bad task_config! Unexpected options #{unexpected_task_options}.")
      end
    end
  end

  CHECK_CAN_BE_SKIPPED_CONDITIONS = {
    Test::Tasks::ConvertSchemasToTs => proc do
      !file_changed?(%r{^app/javascript/types/bootstrap/}i) &&
        !file_changed?(%r{^app/javascript/types/responses/}i) &&
        !file_changed?(%r{^spec/support/schemas/}i) &&
        !file_changed?('tools/json_schemas_to_typescript.rb') &&
        !diff_mentions?('quicktype')
    end,
    Test::Tasks::RunAnnotate => proc do
      !db_schema_changed? &&
        !diff_mentions?('annotate') &&
        !files_added_in?('app/models') &&
        !files_added_in?('app/serializers') &&
        !files_added_in?('spec/factories') &&
        !files_added_in?('spec/serializers')
    end,
    Test::Tasks::RunBrakeman => proc do
      (!(haml_files_changed? || ruby_files_changed?) || running_locally?) &&
        !diff_mentions?('brakeman')
    end,
    Test::Tasks::RunDatabaseConsistency => proc do
      !db_schema_changed? && !diff_mentions?('database_consistency')
    end,
    Test::Tasks::RunToolsTests => proc do
      !file_changed?(%r{^tools/}i) &&
        !file_changed?(%r{^spec/tools/}i) &&
        !diff_mentions?('rubocop')
    end,
    Test::Tasks::RunTsd => proc do
      !file_changed?('app/javascript/types/index.ts') &&
        !diff_mentions?('intersection') &&
        !diff_mentions?('tsc|typescript')
    end,
    Test::Tasks::StartPercy => proc do
      ENV['PERCY_TOKEN'].blank?
    end,
    Test::Tasks::CheckTypescript => proc do
      !files_with_js_changed? &&
        !diff_mentions?('tsc|typescript') &&
        !file_changed?('package.json') &&
        !file_changed?('pnpm-lock.yaml') &&
        !file_changed?('tsconfig.json')
    end,
    Test::Tasks::RunEslint => proc do
      !files_with_js_changed? &&
        !diff_mentions?('eslint') &&
        !file_changed?(/eslint/i) &&
        !file_changed?('package.json') &&
        !file_changed?('pnpm-lock.yaml')
    end,
    Test::Tasks::RunImmigrant => proc { !db_schema_changed? && !diff_mentions?('immigrant') },
    Test::Tasks::RunPrettier => proc do
      all_changed_file_extensions_are_among?(%w[haml lock rb]) &&
        !dotfile_changed? &&
        !diff_mentions?('prettier')
    end,
    Test::Tasks::RunRubocop => proc do
      !ruby_files_changed? &&
        !rubocop_files_changed? &&
        !diff_mentions?('rubocop') &&
        !diff_mentions?('runger_style')
    end,
    Test::Tasks::RunStylelint => proc { !files_with_css_changed? && !diff_mentions?('stylelint') },
    Test::Tasks::SetupDb => proc { running_locally? },
    Test::Tasks::PnpmInstall => proc { running_locally? },
    Test::Tasks::RunVitest => proc do
      !files_with_js_changed? &&
        !diff_mentions?('vitest') &&
        !file_changed?('package.json') &&
        !file_changed?('pnpm-lock.yaml')
    end,
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
      true_requirements = tasks_and_dependencies(true_requirements, skippable_requirements:)

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
    # rubocop:disable Style/CollectionCompact
    new_dependencies =
      self.class.dependency_map.values_at(*(target_tasks - self.class.skips)).
        flatten.reject(&:nil?) - known_dependencies - skippable_requirements
    # rubocop:enable Style/CollectionCompact
    new_dependencies.reject! { can_skip?(_1) }

    if new_dependencies.empty?
      target_tasks
    else
      total_dependencies = target_tasks + new_dependencies
      (target_tasks + tasks_and_dependencies(
        new_dependencies,
        known_dependencies: total_dependencies,
        skippable_requirements:,
      )).flatten.uniq
    end
  end

  memoize \
  def running_locally?
    !ENV.key?('CI')
  end
end
