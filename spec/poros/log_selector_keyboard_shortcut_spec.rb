RSpec.describe LogSelectorKeyboardShortcut do
  subject(:log_selector_keyboard_shortcut) { described_class.new(browser) }

  describe '#shortcut' do
    subject(:shortcut) { log_selector_keyboard_shortcut.shortcut }

    context 'when the browser platform is MacOS' do
      let(:browser) do
        Browser.new(
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 ' \
          '(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
        )
      end

      it 'returns "Cmd+K"' do
        expect(shortcut).to eq('Cmd+K')
      end
    end

    context 'when the browser platform is Linux' do
      let(:browser) do
        Browser.new(
          'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 ' \
          '(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
        )
      end

      it 'returns "Ctrl+K"' do
        expect(shortcut).to eq('Ctrl+K')
      end
    end

    context 'when the browser platform is Windows' do
      let(:browser) do
        Browser.new(
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 ' \
          '(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
        )
      end

      it 'returns "Ctrl+K"' do
        expect(shortcut).to eq('Ctrl+K')
      end
    end
  end
end
