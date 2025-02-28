RSpec.describe Admin::BlogCommentsController do
  context 'when logged in as an AdminUser' do
    before { sign_in(admin_user) }

    let(:admin_user) { admin_users(:admin_user) }

    describe '#index' do
      subject(:get_index) { get(:index) }

      it 'responds with 200' do
        get_index

        expect(response).to have_http_status(200)
      end
    end

    describe '#show' do
      subject(:get_show) { get(:show, params: { id: comment.id }) }

      let(:comment) { comments(:top_level) }

      it 'responds with 200' do
        get_show

        expect(response).to have_http_status(200)
      end
    end
  end
end
