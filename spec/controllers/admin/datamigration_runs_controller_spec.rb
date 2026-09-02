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

      let(:created_at) { Time.zone.parse('2026-09-02 09:17:42.123') }
      let(:completed_at) { created_at + 12.345.seconds }
      let(:updated_at) { completed_at }
      let(:datamigration_run) do
        create(:datamigration_run, created_at:, completed_at:, updated_at:)
      end

      it 'responds with 200' do
        get_show

        expect(response).to have_http_status(200)
      end

      it 'displays all timestamps with seconds and milliseconds' do
        get_show

        expect(response.body).to have_css(
          'tr[data-row="created_at"] td',
          text: 'September 2, 2026 at 9:17:42.123 AM',
        )
        expect(response.body).to have_css(
          'tr[data-row="completed_at"] td',
          text: 'September 2, 2026 at 9:17:54.468 AM',
        )
        expect(response.body).to have_css(
          'tr[data-row="updated_at"] td',
          text: 'September 2, 2026 at 9:17:54.468 AM',
        )
      end
    end
  end
end
