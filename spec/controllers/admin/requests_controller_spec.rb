# frozen_string_literal: true

RSpec.describe Admin::RequestsController do
  let(:admin_user) { admin_users(:admin_user) }

  describe '#index' do
    subject(:get_index) { get(:index) }

    context 'when logged in as an AdminUser' do
      before { sign_in(admin_user) }

      it 'responds with 200' do
        get_index
        expect(response.status).to eq(200)
      end

      context 'when one of the Requests has a parseable user agent' do
        before do
          request.update!(user_agent: <<~USER_AGENT.strip)
            Mozilla/5.0 (Macintosh; Intel Mac OS X 10.16; rv:84.0) Gecko/20100101 Firefox/84.0
          USER_AGENT
        end

        let(:request) { Request.order(id: :desc).first! }

        it 'displays the parsed user agent' do
          get_index
          expect(response.body).to have_text('Firefox 84 on macOS')
        end
      end

      context 'when one of the Requests has an unparseable user agent' do
        before { request.update!(user_agent: user_agent) }

        let(:user_agent) { 'Mozilla/5.0 (compatible; AhrefsBot/7.0; +http://ahrefs.com/robot/)' }
        let(:request) { Request.order(id: :desc).first! }

        it 'displays the raw user agent' do
          get_index
          expect(response.body).to have_text(user_agent)
        end
      end
    end
  end

  describe '#show' do
    subject(:get_show) { get(:show, params: { id: request.id }) }

    let(:request) { Request.first! }

    context 'when logged in as an AdminUser' do
      before { sign_in(admin_user) }

      it 'responds with 200' do
        get_show
        expect(response.status).to eq(200)
      end
    end
  end
end
