# frozen_string_literal: true

# rubocop:disable RSpec/DescribeClass
RSpec.describe 'Sidekiq scheduled jobs' do
  # rubocop:enable RSpec/DescribeClass
  # rubocop:disable Security/YAMLLoad
  subject(:schedule) { YAML.load(ERB.new(File.read('config/sidekiq.yml')).result)[:schedule] }
  # rubocop:enable Security/YAMLLoad

  specify 'all scheduled Sidekiq job classes are indeed defined' do
    expect { schedule.each_key(&:constantize) }.not_to raise_error
  end
end
