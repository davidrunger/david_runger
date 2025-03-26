RSpec.describe Admin::CspReportsController do
  context 'when logged in as an AdminUser' do
    before { sign_in(admin_users(:admin_user)) }

    describe '#index' do
      subject(:get_index) { get(:index) }

      context 'when there is a CspReport with a Firefox user agent' do
        before { CspReport.find_each { it.update!(user_agent: firefox_user_agent) } }

        let(:firefox_user_agent) do
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:105.0) Gecko/20100101 Firefox/105.0'
        end

        it 'shows a pretty version of the user agent' do
          get_index
          expect(response.body).to have_text('Firefox 105')
        end
      end
    end

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
