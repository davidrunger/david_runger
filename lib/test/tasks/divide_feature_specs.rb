class Test::Tasks::DivideFeatureSpecs < Pallets::Task
  include Test::TaskHelpers

  def run
    puts("#{AmazingPrint::Colors.yellow('Dividing feature specs')}...")

    Dir.glob('spec/features/**/*_spec.rb').
      shuffle.
      group_by.with_index { |_file, index| index % 3 }.
      values.
      each_with_index do |array, index|
        letter = ('a'..'c').to_a[index]
        File.write("tmp/feature_specs_#{letter}.txt", array.join(' '))
      end

    record_success_and_log_message('Divided feature specs randomly into three groups.')
  end
end
