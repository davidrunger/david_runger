class Test::Tasks::DivideFeatureSpecs < Pallets::Task
  include Test::TaskHelpers

  NUM_FEATURE_SPEC_GROUPS = 3
  FEATURE_SPECS_TO_SKIP_ON_NON_MAIN_CI = %w[
    spec/features/blog_spec.rb
    spec/features/check_ins_spec.rb
    spec/features/workout_spec.rb
  ].freeze

  def run
    puts("#{AmazingPrint::Colors.yellow('Dividing feature specs')}...")

    FileUtils.mkdir_p('tmp')

    feature_specs_to_run.
      shuffle.
      group_by.with_index { |_file, index| index % NUM_FEATURE_SPEC_GROUPS }.
      values.
      each_with_index do |array, index|
        letter = ('a'..'c').to_a.fetch(index)
        File.write("tmp/feature_specs_#{letter}.txt", array.join(' '))
      end

    record_success_and_log_message(<<~LOG)
      Divided feature specs randomly into #{NUM_FEATURE_SPEC_GROUPS} groups.
    LOG
  end

  private

  def feature_specs_to_run
    files = Dir.glob('spec/features/**/*_spec.rb')

    if non_main_ci?
      files.reject { it.in?(FEATURE_SPECS_TO_SKIP_ON_NON_MAIN_CI) }
    else
      files
    end
  end

  def non_main_ci?
    ENV.fetch('CI', nil) == 'true' &&
      (ENV.fetch('GITHUB_HEAD_REF', nil).presence || ENV.fetch('GITHUB_REF_NAME', nil)) != 'main'
  end
end
