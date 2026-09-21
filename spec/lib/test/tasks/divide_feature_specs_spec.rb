module Test::Tasks ; end

require Rails.root.join('lib/test/task_helpers')
require Rails.root.join('lib/test/tasks/divide_feature_specs')

RSpec.describe(Test::Tasks::DivideFeatureSpecs) do
  subject(:task) { described_class.new }

  describe '#run' do
    let(:feature_spec_groups) do
      [
        %w[a_spec.rb b_spec.rb],
        %w[c_spec.rb],
        [],
      ]
    end

    before do
      allow(task).to receive(:run_ruby_code).and_yield
      allow(task).to receive_messages(
        feature_spec_groups:,
        feature_spec_cost_components_by_file: {
          'a_spec.rb' => { meaningful_lines: 10, example_lines: 20, browser_operation_lines: 30 },
          'b_spec.rb' => { meaningful_lines: 20, example_lines: 10, browser_operation_lines: 0 },
          'c_spec.rb' => { meaningful_lines: 5, example_lines: 0, browser_operation_lines: 10 },
        },
      )
      allow(FileUtils).to receive(:mkdir_p)
      allow(File).to receive(:write)
      allow($stdout).to receive(:puts)
    end

    it 'prints the feature specs in each group' do
      task.run

      expect($stdout).to have_received(:puts).once.with(<<~OUTPUT.chomp)
        FeatureTestsA: total=90 meaningful_lines=30 example_lines=30 browser_operation_lines=30 a_spec.rb b_spec.rb
        FeatureTestsB: total=15 meaningful_lines=5 example_lines=0 browser_operation_lines=10 c_spec.rb
        FeatureTestsC: total=0 meaningful_lines=0 example_lines=0 browser_operation_lines=0
      OUTPUT
    end
  end

  describe '#feature_spec_groups' do
    let(:feature_spec_files) { %w[a_spec.rb b_spec.rb c_spec.rb d_spec.rb e_spec.rb] }
    let(:line_counts) do
      {
        'a_spec.rb' => 50,
        'b_spec.rb' => 40,
        'c_spec.rb' => 30,
        'd_spec.rb' => 20,
        'e_spec.rb' => 10,
      }
    end

    before do
      allow(task).to receive(:meaningful_line_count) { |file| line_counts.fetch(file) }
      allow(task).to receive_messages(example_count: 0, browser_operation_count: 0)
      allow(task).to receive(:rand).and_return(0.69, 0.7, 0.69, 0.7)
    end

    it 'chooses between the two longest specs and assigns each to the lightest group' do
      expect(task.send(:feature_spec_groups, feature_spec_files)).to eq(
        [
          %w[a_spec.rb],
          %w[c_spec.rb e_spec.rb d_spec.rb],
          %w[b_spec.rb],
        ],
      )
    end

    context 'when only one feature spec remains' do
      let(:feature_spec_files) { ['a_spec.rb'] }

      it 'assigns the spec without making a random choice' do
        allow(task).to receive(:rand)

        expect(task.send(:feature_spec_groups, feature_spec_files)).to eq(
          [['a_spec.rb'], [], []],
        )
        expect(task).not_to have_received(:rand)
      end
    end
  end

  describe '#example_count' do
    it 'counts running example declarations but not comments, strings, or non-running examples' do
      Tempfile.create(['feature', '.rb']) do |file|
        file.write(<<~RUBY)
          RSpec.describe 'a feature' do
            it 'runs an example' do
            end
            specify 'runs another example' do
            end
            # it 'is only a comment' do
            # end
            value = 'it is only a string'
            fit 'is focused' do
            end
            xit 'is skipped' do
            end
          end
        RUBY
        file.flush

        expect(task.send(:example_count, file.path)).to eq(2)
      end
    end
  end

  describe '#browser_operation_count' do
    it 'counts Capybara and wait operations but not comments or strings' do
      Tempfile.create(['feature', '.rb']) do |file|
        file.write(<<~RUBY)
          RSpec.describe 'a feature' do
            visit '/the-feature'
            click_on 'Continue'
            page.find('#details')
            page.has_css?('#details')
            wait_for 'the details'
            wait_for_check_ins_channel_connection
            sleep 1
            # visit '/a-comment'
            value = 'click_on is only a string'
          end
        RUBY
        file.flush

        expect(task.send(:browser_operation_count, file.path)).to eq(7)
      end
    end
  end

  describe '#meaningful_line_count' do
    it 'excludes blank lines, comments, and heredoc bodies' do
      Tempfile.create(['feature', '.rb']) do |file|
        file.write(<<~'RUBY')
          # A comment-only line.
          RSpec.describe 'a feature' do

            value = <<~TEXT
              heredoc content
              #{interpolated_content}
            TEXT
          =begin
          An embedded documentation comment.
          =end
            expect(value).to be_present # An inline comment.
          end
        RUBY
        file.flush

        expect(task.send(:meaningful_line_count, file.path)).to eq(4)
      end
    end
  end
end
