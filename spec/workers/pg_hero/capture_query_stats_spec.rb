RSpec.describe PgHero::CaptureQueryStats do
  subject(:capture_query_stats) { PgHero::CaptureQueryStats.new }

  describe '#perform' do
    subject(:perform) { capture_query_stats.perform }

    it 'calls PgHero.capture_query_stats' do
      allow(PgHero).to receive(:capture_query_stats)

      perform

      expect(PgHero).to have_received(:capture_query_stats)
    end
  end
end
