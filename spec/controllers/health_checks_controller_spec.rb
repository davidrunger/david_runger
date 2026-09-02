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
        allow(User).
          to receive(:select).
          with(:id).
          and_raise(ActiveRecord::ConnectionNotEstablished)
      end

      it 'raises an error' do
        expect { get_index }.to raise_error(ActiveRecord::ConnectionNotEstablished)

        expect(User).to have_received(:select).with(:id).once
      end
    end

    context 'when Redis is not accessible' do
      before do
        allow($redis_pool).
          to receive(:with).
          and_raise(Redis::CannotConnectError)
      end

      it 'raises an error' do
        expect { get_index }.to raise_error(Redis::CannotConnectError)

        expect($redis_pool).to have_received(:with).once
      end
    end
  end
end
