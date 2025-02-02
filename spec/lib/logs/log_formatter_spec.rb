RSpec.describe Logs::LogFormatter do
  subject(:log_formatter) { Logs::LogFormatter.new(data) }

  let(:data) { {} }

  describe '#color_background_and_style' do
    subject(:color_background_and_style) do
      log_formatter.send(:color_background_and_style, key, value)
    end

    context 'when called for allocations of 80,000' do
      let(:key) { 'allocations' }
      let(:value) { 80_000 }

      it 'returns :red' do
        expect(color_background_and_style).to eq(:red)
      end
    end

    context 'when called for a duration of 500 (milliseconds)' do
      let(:key) { 'duration' }
      let(:value) { 500 }

      it 'returns :red' do
        expect(color_background_and_style).to eq(:red)
      end
    end
  end
end
