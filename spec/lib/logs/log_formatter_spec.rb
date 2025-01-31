RSpec.describe Logs::LogFormatter do
  subject(:log_formatter) { Logs::LogFormatter.new(data) }

  let(:data) { {} }

  describe '#call' do
    subject(:call) { log_formatter.call }

    context 'when Rails env is test and Rainbow is not enabled' do
      before { expect(Rails.env.test?).to eq(true) }

      around do |spec|
        Rainbow.with(enabled: false) do
          spec.run
        end
      end

      context 'when duration is >= 500' do
        let(:data) { super().merge(duration:) }
        let(:duration) { 500 }

        it 'returns a string with key=value for the duration' do
          expect(call).to eq("duration=#{duration}")
        end
      end
    end
  end
end
