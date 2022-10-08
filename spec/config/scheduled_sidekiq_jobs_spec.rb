# frozen_string_literal: true

# rubocop:disable RSpec/DescribeClass
RSpec.describe 'Sidekiq scheduled jobs' do
  # rubocop:enable RSpec/DescribeClass
  subject(:schedule) { YAML.load(ERB.new(File.read('config/schedjewel.yml')).result) }

  specify 'all scheduled Sidekiq job classes are indeed defined' do
    expect { schedule['jobs'].map { |job_hash| job_hash['job'].constantize } }.not_to raise_error
  end
end
