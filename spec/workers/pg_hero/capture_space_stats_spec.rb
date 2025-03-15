RSpec.describe PgHero::CaptureSpaceStats do
  subject(:capture_space_stats) { PgHero::CaptureSpaceStats.new }

  describe '#perform' do
    subject(:perform) { capture_space_stats.perform }

    it 'calls PgHero.capture_space_stats' do
      allow(PgHero).to receive(:capture_space_stats)

      perform

      expect(PgHero).to have_received(:capture_space_stats)
    end
  end
end
