RSpec.describe PgHero::CleanQueryStats do
  subject(:clean_query_stats) { PgHero::CleanQueryStats.new }

  describe '#perform' do
    subject(:perform) { clean_query_stats.perform }

    it 'calls PgHero.clean_query_stats' do
      allow(PgHero).to receive(:clean_query_stats)

      perform

      expect(PgHero).to have_received(:clean_query_stats)
    end
  end
end
