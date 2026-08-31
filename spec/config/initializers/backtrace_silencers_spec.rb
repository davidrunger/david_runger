RSpec.describe 'backtrace silencers' do # rubocop:disable RSpec/DescribeClass
  let(:response_serialization_frames) do
    [
      'app/controllers/api/base_controller.rb:3',
      'app/controllers/concerns/schema_validatable.rb:10',
      'app/helpers/window_data_helper.rb:6',
      'app/poros/json_schema_validator.rb:52',
    ]
  end
  let(:application_query_frame) { 'app/controllers/api/items_controller.rb:16' }

  it 'filters response serialization from query source backtraces' do
    expect(
      ActiveRecord::LogSubscriber.backtrace_cleaner.clean(
        [*response_serialization_frames, application_query_frame],
      ),
    ).to contain_exactly(application_query_frame)
  end

  it 'does not filter response serialization from other backtraces (e.g. exceptions)' do
    expect(
      Rails.backtrace_cleaner.clean(response_serialization_frames),
    ).to match_array(response_serialization_frames)
  end
end
