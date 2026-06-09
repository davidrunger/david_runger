RSpec.describe(Admin::EventsController) do
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
      subject(:get_show) { get(:show, params: { id: event.id }) }

      let(:event) { events(:event) }

      it 'responds with 200' do
        get_show
        expect(response).to have_http_status(200)
      end

      it 'displays the IP address with a link to requests from that IP' do
        get_show

        expect(response.body).to have_text(event.ip)
        expect(response.body).to have_link(
          'requests',
          href: admin_requests_path(q: { ip_eq: event.ip }),
        )
      end
    end
  end
end
