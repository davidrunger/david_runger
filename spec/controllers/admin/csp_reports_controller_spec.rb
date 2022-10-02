# frozen_string_literal: true

RSpec.describe Admin::CspReportsController do
  context 'when logged in as an AdminUser' do
    before { sign_in(admin_users(:admin_user)) }

    describe '#show' do
      subject(:get_show) { get(:show, params: { id: csp_report.id }) }

      let(:csp_report) { csp_reports(:csp_report) }

      it 'responds with 200' do
        get_show
        expect(response).to have_http_status(200)
      end
    end
  end
end
