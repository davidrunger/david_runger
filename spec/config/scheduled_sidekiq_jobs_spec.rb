# rubocop:disable RSpec/DescribeClass
RSpec.describe 'Sidekiq scheduled jobs' do
  # rubocop:enable RSpec/DescribeClass
  subject(:schedule) { YAML.load_file('config/skedjewel.yml') }

  specify 'all scheduled Sidekiq job classes are indeed defined' do
    expect do
      schedule['jobs_by_rails_env'].values.map do |jobs_for_env|
        jobs_for_env.keys.map(&:constantize)
      end
    end.not_to raise_error
  end
end
