# frozen_string_literal: true

# rubocop:disable RSpec/DescribeClass
RSpec.describe 'Sidekiq scheduled jobs' do
  # rubocop:enable RSpec/DescribeClass
  subject(:schedule) { YAML.load_file('config/skedjewel.yml') }

  specify 'all scheduled Sidekiq job classes are indeed defined' do
    expect { schedule['jobs'].keys.map(&:constantize) }.not_to raise_error
  end
end
