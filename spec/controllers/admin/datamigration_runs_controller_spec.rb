RSpec.describe Admin::DatamigrationRunsController do
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
      subject(:get_show) { get(:show, params: { id: datamigration_run.id }) }

      let(:datamigration_run) { DatamigrationRun.first! }

      it 'responds with 200' do
        get_show

        expect(response).to have_http_status(200)
      end
    end
  end
end
