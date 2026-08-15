RSpec.describe Cuprite::BrowserLogger do
  subject(:logger) { described_class.new }

  before do
    described_class.browser_log_entries.clear
    allow($stdout).to receive(:puts)
  end

  describe '#log_entry' do
    let(:entry) do
      {
        'level' => 'error',
        'source' => 'network',
        'text' => described_class::BLOCKED_BY_CLIENT_MESSAGE,
        'url' => url,
      }
    end

    context 'when a public uploads request was blocked by the browser' do
      let(:url) { "#{Rails.configuration.public_uploads_origin}/portfolio.png" }

      it 'ignores the log entry' do
        logger.log_entry(entry)

        expect(described_class.browser_log_entries).to be_empty
      end
    end

    context 'when another request was blocked by the browser' do
      let(:url) { 'https://example.com/portfolio.png' }

      it 'records the browser log entry' do
        logger.log_entry(entry)

        expect(described_class.browser_log_entries).to eq([entry])
      end
    end

    context 'when a different public uploads error is logged' do
      let(:url) { "#{Rails.configuration.public_uploads_origin}/portfolio.png" }

      before { entry['text'] = 'A different network error' }

      it 'records the browser log entry' do
        logger.log_entry(entry)

        expect(described_class.browser_log_entries).to eq([entry])
      end
    end
  end
end
