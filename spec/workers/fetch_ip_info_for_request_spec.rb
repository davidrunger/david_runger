# frozen_string_literal: true

RSpec.describe FetchIpInfoForRequest do
  subject(:worker) { FetchIpInfoForRequest.new }

  let(:request) { Request.last! }

  before { request.update!(location: nil, isp: nil) }

  describe '#perform' do
    subject(:perform) { worker.perform(request.id) }

    let(:location) { 'San Diego, CA, US' }
    let(:isp) { 'Comcast' }

    context 'when IP address info is already cached', :cache do
      before do
        Rails.cache.write("ip-info:#{request.ip}", { location:, isp: }, {})
      end

      it 'updates the request with the IP address info' do
        expect {
          perform
        }.to change {
          request.reload.attributes.values_at(*%w[location isp])
        }.from([nil, nil]).
          to([location, isp])
      end
    end

    context 'when the request IP is a localhost IP' do
      before { request.update!(ip: '127.0.0.1') } # rubocop:disable Style/IpAddresses

      it 'does not make a request to Rails.cache' do
        expect(Rails.cache).not_to receive(:fetch)
        perform
      end
    end
  end
end
