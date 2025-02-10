RSpec.describe IpBlocks::StoreRequestBlockInRedis do
  subject(:store_request_block_action) do
    IpBlocks::StoreRequestBlockInRedis.new(store_request_block_params)
  end

  let(:store_request_block_params) do
    {
      ip: Faker::Internet.ip_v4_address,
      path: '/wordpress/themes?admin=true',
    }
  end

  describe 'initializing the action' do
    context 'when the inputs are valid' do
      it 'does not raise an error' do
        expect { store_request_block_action }.not_to raise_error
      end
    end

    context 'when the inputs are not valid' do
      let(:store_request_block_params) do
        {
          ip: 'this is not an IP',
          path: 'this is not a path',
        }
      end

      it 'raises an error' do
        expect { store_request_block_action }.to raise_error(
          RungerActions::TypeMismatch,
          <<~ERROR.squish)
            One or more required params are of the wrong type: `ip` is expected to be shaped like
            String validating {format: {with: /\\A[.:0-9a-f]{3,39}\\z/}}, but was `"this is not an
            IP"` ; `path` is expected to be shaped like String validating
            {format: {with: /\\A\\//}}, but was `"this is not a path"`.
          ERROR
      end
    end
  end

  context 'when the IP address is an IPv6 format' do
    let(:store_request_block_params) { super().merge(ip: Faker::Internet.ip_v6_address) }

    it 'does not raise an error' do
      expect { store_request_block_action }.not_to raise_error
    end

    context 'when it is a local IP address' do
      let(:store_request_block_params) { super().merge(ip: '::1') }

      it 'does not raise an error' do
        expect { store_request_block_action }.not_to raise_error
      end
    end
  end
end
