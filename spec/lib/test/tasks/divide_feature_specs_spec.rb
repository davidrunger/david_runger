require Rails.root.join('lib/test/namespaces')
require Rails.root.join('lib/test/task_helpers')
require Rails.root.join('lib/test/tasks/divide_feature_specs')

RSpec.describe Test::Tasks::DivideFeatureSpecs do
  subject(:task) { described_class.new }

  let(:feature_spec_paths) do
    %w[
      spec/features/blog_spec.rb
      spec/features/check_ins_spec.rb
      spec/features/home_spec.rb
      spec/features/workout_spec.rb
    ]
  end

  before do
    allow(Dir).to receive(:glob).
      with('spec/features/**/*_spec.rb').
      and_return(feature_spec_paths)
  end

  describe '#feature_specs_to_run' do
    subject(:selected_feature_spec_paths) { task.send(:feature_specs_to_run) }

    context 'when CI is running on a non-main branch' do
      around do |spec|
        ClimateControl.modify(
          CI: 'true',
          GITHUB_HEAD_REF: 'feature-branch',
          GITHUB_REF_NAME: '42/merge',
        ) { spec.run }
      end

      it 'excludes the slow feature specs' do
        expect(selected_feature_spec_paths).to contain_exactly(
          'spec/features/home_spec.rb',
        )
      end
    end

    context 'when CI is running on main' do
      around do |spec|
        ClimateControl.modify(
          CI: 'true',
          GITHUB_HEAD_REF: nil,
          GITHUB_REF_NAME: 'main',
        ) { spec.run }
      end

      it 'includes all feature specs' do
        expect(selected_feature_spec_paths).to match_array(feature_spec_paths)
      end
    end

    context 'when not running in CI' do
      around do |spec|
        ClimateControl.modify(
          CI: nil,
          GITHUB_HEAD_REF: nil,
          GITHUB_REF_NAME: nil,
        ) { spec.run }
      end

      it 'includes all feature specs' do
        expect(selected_feature_spec_paths).to match_array(feature_spec_paths)
      end
    end
  end
end
