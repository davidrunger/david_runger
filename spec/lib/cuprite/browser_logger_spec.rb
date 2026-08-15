RSpec.describe Cuprite::BrowserLogger do
  subject(:logger) { described_class.new }

  before do
    described_class.browser_log_entries.clear
    allow($stdout).to receive(:puts)
  end

  describe '#log_entry' do
    it 'records browser log entries' do
      entry = {
        'level' => 'error',
        'text' => 'Failed to load resource: net::ERR_BLOCKED_BY_CLIENT.Inspector',
      }

      logger.log_entry(entry)

      expect(described_class.browser_log_entries).to eq([entry])
    end
  end
end
