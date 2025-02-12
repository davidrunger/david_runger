class Test::Tasks::DivideFeatureSpecs < Pallets::Task
  include Test::TaskHelpers

  NUM_FEATURE_SPEC_GROUPS = 2

  def run
    puts("#{AmazingPrint::Colors.yellow('Dividing feature specs')}...")

    Dir.glob('spec/features/**/*_spec.rb').
      shuffle.
      group_by.with_index { |_file, index| index % NUM_FEATURE_SPEC_GROUPS }.
      values.
      each_with_index do |array, index|
        letter = ('a'..'b').to_a.fetch(index)
        File.write("tmp/feature_specs_#{letter}.txt", array.join(' '))
      end

    record_success_and_log_message(<<~LOG)
      Divided feature specs randomly into #{NUM_FEATURE_SPEC_GROUPS} groups.
    LOG
  end
end
