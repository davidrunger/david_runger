# frozen_string_literal: true

RSpec.describe IpBlocks::StoreRequestBlockInRedis do
  subject(:store_request_block_action) do
    IpBlocks::StoreRequestBlockInRedis.new(store_request_block_params)
  end

  let(:store_request_block_params) do
    {
      ip: '123.456.987.12',
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
          ActiveActions::TypeMismatch,
          <<~ERROR.squish)
            One or more required params are of the wrong type: `ip` is expected to be shaped like
            String validating {:format=>{:with=>/[.0-9]{7,15}/}}, but was `"this is not an IP"` ;
            `path` is expected to be shaped like String validating {:format=>{:with=>/\\A\\//}}, but
            was `"this is not a path"`.
          ERROR
      end
    end
  end
end
