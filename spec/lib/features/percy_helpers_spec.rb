RSpec.describe(Features::PercyHelpers) do
  subject(:helper) do
    Class.new do
      include RSpec::Matchers
      include RSpec::Wait
      include Features::PercyHelpers

      attr_accessor :page
    end.new.tap { it.page = page }
  end

  let(:page) do
    Class.new do
      attr_reader :snapshot_name

      def percy_snapshot(snapshot_name)
        @snapshot_name = snapshot_name
      end
    end.new
  end

  let(:healthcheck_url) { 'http://127.0.0.1:5338/percy/healthcheck' }

  describe '#take_percy_snapshot' do
    context 'when Percy is enabled' do
      around do |spec|
        ClimateControl.modify(PERCY_TOKEN: 'token') { spec.run }
      end

      context 'when Percy starts before the timeout' do
        before do
          stub_request(:get, healthcheck_url).to_return(status: 200)
        end

        it 'waits for Percy before taking the snapshot' do
          helper.take_percy_snapshot('Snapshot name')

          expect(page.snapshot_name).to eq('Snapshot name')
          expect(a_request(:get, healthcheck_url)).to have_been_made.once
        end
      end

      context 'when Percy does not start before the timeout' do
        before do
          stub_const('Features::PercyHelpers::PERCY_WAIT_TIMEOUT', 0)
          stub_request(:get, healthcheck_url).to_return(status: 503)
        end

        it 'raises an expectation failure before taking the snapshot' do
          expect do
            helper.take_percy_snapshot('Snapshot name')
          end.to raise_error(
            RSpec::Expectations::ExpectationNotMetError,
            'Percy did not start before the snapshot',
          )

          expect(page.snapshot_name).to be_nil
        end
      end
    end

    context 'when Percy is disabled' do
      around do |spec|
        ClimateControl.modify(PERCY_TOKEN: nil) { spec.run }
      end

      it 'takes the snapshot without checking Percy health' do
        helper.take_percy_snapshot('Snapshot name')

        expect(page.snapshot_name).to eq('Snapshot name')
        expect(a_request(:get, healthcheck_url)).not_to have_been_made
      end
    end
  end
end
