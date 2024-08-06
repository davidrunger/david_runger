RSpec.describe FetchIpInfoForRecord do
  subject(:worker) { FetchIpInfoForRecord.new }

  describe '#perform' do
    subject(:perform) { worker.perform(class_name, record.id) }

    let(:location) { 'San Diego, CA, US' }
    let(:isp) { 'Comcast' }

    context 'when class_name is "Request"' do
      let(:class_name) { 'Request' }
      let(:request) { Request.first! }
      let(:record) { request }

      before { request.update!(location: nil, isp: nil) }

      context 'when IP address info is already cached', :cache do
        before do
          Rails.cache.write("ip-info:#{request.ip}", { location:, isp: })
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
        before { request.update!(ip: '127.0.0.1') }

        it 'does not make a request to Rails.cache' do
          expect(Rails.cache).not_to receive(:fetch)
          perform
        end
      end
    end

    context 'when class_name is "IpBlock"' do
      let(:class_name) { 'IpBlock' }
      let(:ip_block) { IpBlock.first! }
      let(:record) { ip_block }

      before { ip_block.update!(location: nil, isp: nil) }

      context 'when IP address info is already cached', :cache do
        before do
          Rails.cache.write("ip-info:#{ip_block.ip}", { location:, isp: })
        end

        it 'updates the IpBlock with the IP address info' do
          expect {
            perform
          }.to change {
            ip_block.reload.attributes.values_at(*%w[location isp])
          }.from([nil, nil]).
            to([location, isp])
        end
      end
    end
  end
end
