# frozen_string_literal: true

RSpec.describe Admin::ApplicationController do
  controller(Admin::ApplicationController) do
    def index
      render(plain: Admin::ApplicationController::STUBBED_INDEX_BODY)
    end
  end

  before do
    stub_const(
      'Admin::ApplicationController::STUBBED_INDEX_BODY',
      'This is the #index action response body. I hope you like it!',
    )
  end

  describe '#authenticate_admin' do
    before { sign_in(user) }

    let(:user) { users(:admin) }
    let(:get_index) { get(:index) }

    context 'when logged in as an admin user' do
      before { expect(user).to be_admin }

      it 'authorizes the request' do
        expect(controller).to receive(:render).and_call_original
        get_index
      end

      it 'responds with the requested action/content' do
        get_index
        expect(response.status).to eq(200)
        expect(response.body).to eq(Admin::ApplicationController::STUBBED_INDEX_BODY)
      end
    end

    context 'when logged in as a non-admin user' do
      before { expect(user).not_to be_admin }

      let(:user) { users(:user) }

      it 'does not authorize the request' do
        expect(controller).not_to receive(:render)
        get_index
      end

      it 'redirects to the root path' do
        get_index
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when not logged in' do
      before { controller.sign_out_all_scopes }

      it 'does not authorize the request' do
        expect(controller).not_to receive(:render)
        get_index
      end

      it 'redirects to the login page' do
        get_index
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
