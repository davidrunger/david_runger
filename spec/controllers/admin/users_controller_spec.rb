# frozen_string_literal: true

RSpec.describe Admin::UsersController do
  before { sign_in(admin_user) }

  let(:admin_user) { users(:admin) }
  let(:user) { User.where.not(id: admin_user).first! }

  describe '#index' do
    subject(:get_index) { get(:index) }

    context 'when there are 20 users or fewer' do
      before do
        users_to_preserve = User.limit(20)
        User.where.not(id: users_to_preserve).destroy_all
      end

      it 'renders the email of each user' do
        get_index

        User.pluck(:email).each do |user_email|
          expect(response.body).to have_text(user_email)
        end
      end
    end
  end

  describe '#show' do
    subject(:get_show) { get(:show, params: { id: user.id }) }

    let(:user) { User.first! }

    it 'renders the email of the user' do
      get_show

      expect(response.body).to have_text(user.email)
    end
  end

  describe '#update' do
    subject(:patch_update) { patch(:update, params: { id: user.id, user: user_params }) }

    context 'when user has a phone number' do
      before { expect(user.phone).to be_present }

      context 'when submitting a phone of "" (blank string)' do
        let(:user_params) { { phone: '' } }

        it "changes the user's phone to `nil`" do
          expect { patch_update }.
            to change { user.reload.phone }.
            from(String).
            to(nil)
        end
      end
    end
  end
end
