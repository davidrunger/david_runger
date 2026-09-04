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
      allow(task).to receive(:feature_spec_groups).and_return(feature_spec_groups)
      allow(FileUtils).to receive(:mkdir_p)
      allow(File).to receive(:write)
      allow($stdout).to receive(:puts)
    end

    it 'prints the feature specs in each group' do
      task.run

      expect($stdout).to have_received(:puts).once.with(<<~OUTPUT.chomp)
        Feature spec group a: a_spec.rb b_spec.rb
        Feature spec group b: c_spec.rb
        Feature spec group c:
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
