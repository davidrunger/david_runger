RSpec.describe 'request logging', type: :controller do
  describe HomeController do
    context 'when request_id somehow is not set' do
      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(ActionController::TestRequest).
          to receive(:headers).
          and_wrap_original do |original_headers_method|
            headers = original_headers_method.call
            headers['action_dispatch.request_id'] = nil
            headers
          end
        # rubocop:enable RSpec/AnyInstance
      end

      it 'reports via Rails.error' do
        expect(Rails.error).
          to receive(:report).
          with(Request::CreateRequestError, context: { request_id: nil }).
          and_call_original

        get(:upgrade_browser)
      end
    end
  end
end
