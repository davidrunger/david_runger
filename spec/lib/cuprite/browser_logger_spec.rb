RSpec.describe Cuprite::BrowserLogger do
  subject(:logger) { described_class.new }

  before do
    described_class.csp_violations.clear
    allow($stdout).to receive(:puts)
  end

  describe '#log_entry' do
    it 'records Content Security Policy violations' do
      message = 'Refused to execute inline script because it violates Content Security Policy.'

      logger.log_entry('text' => message)

      expect(described_class.csp_violations).to eq([message])
    end

    it 'ignores log entries that are not Content Security Policy violations' do
      logger.log_entry('text' => 'A normal browser log entry.')

      expect(described_class.csp_violations).to be_empty
    end
  end
end
