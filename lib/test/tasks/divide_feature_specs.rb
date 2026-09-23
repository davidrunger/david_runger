require 'capybara/dsl'
require 'ripper'

class Test::Tasks::DivideFeatureSpecs < Pallets::Task
  include Test::TaskHelpers

  EXAMPLE_DECLARATION_NAMES = %w[
    example
    it
    specify
  ].freeze
  # Use a modest source-line equivalent for the per-example hooks that run
  # regardless of the example's body.
  EXAMPLE_COST_IN_MEANINGFUL_LINES = 10
  CAPYBARA_OPERATION_NAMES = Capybara::Session::DSL_METHODS.
    map { |name| name.to_s.delete_suffix('?').delete_suffix('!') }.
    uniq.freeze
  # These operations are provided by Ruby, Percy, or this application's helpers.
  ADDITIONAL_BROWSER_OPERATION_NAMES = %w[
    sleep
    take_percy_snapshot
    wait_for
  ].freeze
  BROWSER_OPERATION_COST_IN_MEANINGFUL_LINES = 20
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
  TOP_SPEC_SELECTION_PROBABILITY = 0.85

  def run
    run_ruby_code(
      task_description: <<~DESCRIPTION.squish,
        Dividing feature specs by source size, example count, and browser operation count into #{NUM_FEATURE_SPEC_GROUPS} groups
      DESCRIPTION
    ) do
      FileUtils.mkdir_p('tmp')

      feature_spec_files = Dir.glob('spec/features/**/*_spec.rb')
      cost_components_by_file = feature_spec_cost_components_by_file(feature_spec_files)
      grouping_output =
        feature_spec_groups(feature_spec_files, cost_components_by_file:).
          each_with_index.map do |feature_specs, index|
            letter = ('a'..'c').to_a.fetch(index)
            File.write("tmp/feature_specs_#{letter}.txt", feature_specs.join(' '))
            cost_breakdown = feature_spec_cost_breakdown(feature_specs, cost_components_by_file)
            ["FeatureTests#{letter.upcase}:", *cost_breakdown, *feature_specs].join(' ')
          end

      puts(grouping_output.join("\n"))
    end
  end

  private

  def feature_spec_groups(
    feature_spec_files,
    cost_components_by_file: feature_spec_cost_components_by_file(feature_spec_files)
  )
    remaining_feature_specs =
      feature_spec_files.
        map { |file| [file, cost_components_by_file.fetch(file).values.sum] }.
        sort_by { |file, cost| [-cost, file] }
    feature_spec_groups = Array.new(NUM_FEATURE_SPEC_GROUPS) { [] }
    group_costs = Array.new(NUM_FEATURE_SPEC_GROUPS, 0)

    until remaining_feature_specs.empty?
      selected_index =
        if remaining_feature_specs.one? || rand < TOP_SPEC_SELECTION_PROBABILITY
          0
        else
          1
        end
      selected_file, selected_cost = remaining_feature_specs.delete_at(selected_index)
      lightest_group_index =
        group_costs.each_index.min_by { |index| group_costs.fetch(index) }

      feature_spec_groups.fetch(lightest_group_index) << selected_file
      group_costs[lightest_group_index] += selected_cost
    end

    feature_spec_groups
  end

  def feature_spec_cost_breakdown(feature_specs, cost_components_by_file)
    cost_components =
      feature_specs.each_with_object(Hash.new(0)) do |file, totals|
        cost_components_by_file.fetch(file).each do |component, cost|
          totals[component] += cost
        end
      end

    [
      "total=#{cost_components.values.sum}",
      "meaningful_lines=#{cost_components.fetch(:meaningful_lines, 0)}",
      "example_lines=#{cost_components.fetch(:example_lines, 0)}",
      "browser_operation_lines=#{cost_components.fetch(:browser_operation_lines, 0)}",
    ]
  end

  def feature_spec_cost_components_by_file(feature_spec_files)
    feature_spec_files.index_with { |file| feature_spec_cost_components(file) }
  end

  def feature_spec_cost_components(file)
    {
      meaningful_lines: meaningful_line_count(file),
      example_lines: example_count(file) * EXAMPLE_COST_IN_MEANINGFUL_LINES,
      browser_operation_lines:
        browser_operation_count(file) * BROWSER_OPERATION_COST_IN_MEANINGFUL_LINES,
    }
  end

  def example_count(file)
    source_lines = File.readlines(file)
    example_line_numbers = {}

    Ripper.lex(source_lines.join).each do |(position, token_type, token, _state)|
      line_number, column = position
      line = source_lines.fetch(line_number - 1)

      if (
        token_type == :on_ident &&
        EXAMPLE_DECLARATION_NAMES.include?(token) &&
        line[0, column].match?(/\A\s*\z/)
      )
        example_line_numbers[line_number] = true
      end
    end

    example_line_numbers.length
  end

  def browser_operation_count(file)
    Ripper.lex(File.read(file)).count do |(_position, token_type, token, _state)|
      normalized_token = token.delete_suffix('?').delete_suffix('!')

      token_type == :on_ident &&
        (
          CAPYBARA_OPERATION_NAMES.include?(normalized_token) ||
          ADDITIONAL_BROWSER_OPERATION_NAMES.include?(normalized_token) ||
          normalized_token.start_with?('wait_for_')
        )
    end
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
