RSpec.describe(HealthChecksController) do
  describe '#index' do
    subject(:get_index) { get(:index) }

    context 'when Postgres and Redis are both accessible' do
      it 'returns 200' do
        get_index

        expect(response).to have_http_status(200)
      end
    end

    context 'when Postgres is not accessible' do
      before do
        expect(User).
          to receive(:select).
          with(:id).
          exactly(:once).
          and_raise(ActiveRecord::ConnectionNotEstablished)
      end

      it 'raises an error' do
        expect { get_index }.to raise_error(ActiveRecord::ConnectionNotEstablished)
      end
    end

    context 'when Redis is not accessible' do
      before do
        expect($redis_pool).
          to receive(:with).
          exactly(:once).
          and_raise(Redis::CannotConnectError)
      end

      it 'raises an error' do
        expect { get_index }.to raise_error(Redis::CannotConnectError)
      end
    end
  end
end
