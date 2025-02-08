RSpec.describe(Admin::CiStepResultsController) do
  context 'when logged in as an AdminUser' do
    before { sign_in(admin_users(:admin_user)) }

    describe '#index' do
      subject(:get_index) { get(:index) }

      it 'responds with 200' do
        get_index

        expect(response).to have_http_status(200)
      end
    end

    describe '#show' do
      subject(:get_show) { get(:show, params: { id: ci_step_result.id }) }

      let(:ci_step_result) { CiStepResult.first! }

      it 'responds with 200' do
        get_show

        expect(response).to have_http_status(200)
      end
    end
  end
end
