RSpec.describe Cuprite::BrowserLogger do
  subject(:logger) { described_class.new }

  before do
    described_class.browser_log_entries.clear
    described_class.browser_log_entries_to_ignore.clear
    allow($stdout).to receive(:puts)
  end

  describe '#log_entry' do
    let(:url) { 'https://example.com/portfolio.png' }

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

    context 'when the log entry matches an entry configured to be ignored' do
      before do
        described_class.ignore_browser_log_entries_matching(
          'source' => 'network',
          'text' => /BLOCKED_BY_CLIENT/,
        )
      end

      it 'ignores the log entry' do
        logger.log_entry(entry)

        expect(described_class.browser_log_entries).to be_empty
      end
    end

    context 'when the log entry does not match an entry configured to be ignored' do
      before do
        described_class.ignore_browser_log_entries_matching(
          'source' => 'network',
          'text' => /different network error/,
        )
      end

      it 'records the browser log entry' do
        logger.log_entry(entry)

        expect(described_class.browser_log_entries).to eq([entry])
      end
    end
  end
end
