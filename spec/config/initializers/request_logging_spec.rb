# frozen_string_literal: true

RSpec.describe 'request logging', type: :controller do
  describe HomeController do
    context 'when request_id somehow is not set' do
      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(ActionController::TestRequest).
          to receive(:headers).
          and_wrap_original do |request|
            headers = request.call
            headers['action_dispatch.request_id'] = nil
            headers
          end
        # rubocop:enable RSpec/AnyInstance
      end

      it 'sends a warning to Rollbar' do
        expect(Rollbar).
          to receive(:warn).
          with(Request::CreateRequestError, { request_id: nil }).
          and_call_original

        get(:upgrade_browser)
      end
    end
  end
end
