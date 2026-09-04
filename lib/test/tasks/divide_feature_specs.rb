require 'ripper'

class Test::Tasks::DivideFeatureSpecs < Pallets::Task
  include Test::TaskHelpers

  IGNORED_RUBY_TOKEN_TYPES = %i[
    on___end__
    on_comment
    on_embdoc
    on_embdoc_beg
    on_embdoc_end
    on_ignored_nl
    on_ignored_sp
    on_nl
    on_sp
  ].freeze
  NUM_FEATURE_SPEC_GROUPS = 3
  TOP_SPEC_SELECTION_PROBABILITY = 0.7

  def run
    run_ruby_code(
      task_description: <<~DESCRIPTION.squish,
        Dividing feature specs by meaningful line count into #{NUM_FEATURE_SPEC_GROUPS} groups
      DESCRIPTION
    ) do
      FileUtils.mkdir_p('tmp')

      grouping_output =
        feature_spec_groups(Dir.glob('spec/features/**/*_spec.rb')).
          each_with_index.map do |feature_specs, index|
            letter = ('a'..'c').to_a.fetch(index)
            File.write("tmp/feature_specs_#{letter}.txt", feature_specs.join(' '))
            ["Feature spec group #{letter}:", *feature_specs].join(' ')
          end

      puts(grouping_output.join("\n"))
    end
  end

  private

  def feature_spec_groups(feature_spec_files)
    remaining_feature_specs =
      feature_spec_files.
        map { |file| [file, meaningful_line_count(file)] }.
        sort_by { |file, line_count| [-line_count, file] }
    feature_spec_groups = Array.new(NUM_FEATURE_SPEC_GROUPS) { [] }
    group_line_counts = Array.new(NUM_FEATURE_SPEC_GROUPS, 0)

    until remaining_feature_specs.empty?
      selected_index =
        if remaining_feature_specs.one? || rand < TOP_SPEC_SELECTION_PROBABILITY
          0
        else
          1
        end
      selected_file, selected_line_count = remaining_feature_specs.delete_at(selected_index)
      lightest_group_index =
        group_line_counts.each_index.min_by { |index| group_line_counts.fetch(index) }

      feature_spec_groups.fetch(lightest_group_index) << selected_file
      group_line_counts[lightest_group_index] += selected_line_count
    end

    feature_spec_groups
  end

  def meaningful_line_count(file)
    heredoc_depth = 0
    meaningful_line_numbers = {}

    Ripper.lex(File.read(file)).each do |(position, token_type, _token, _state)|
      line_number, = position

      if token_type == :on_heredoc_beg
        meaningful_line_numbers[line_number] = true
        heredoc_depth += 1
      elsif token_type == :on_heredoc_end
        heredoc_depth -= 1
      elsif heredoc_depth.zero? && IGNORED_RUBY_TOKEN_TYPES.exclude?(token_type)
        meaningful_line_numbers[line_number] = true
      end
    end

    meaningful_line_numbers.length
  end
end
