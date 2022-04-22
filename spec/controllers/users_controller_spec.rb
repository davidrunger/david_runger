# frozen_string_literal: true

RSpec.describe UsersController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#edit' do
    subject(:get_edit) { get(:edit, params: { id: user.id }) }

    it 'renders a form to create a new auth token' do
      get_edit

      expect(response.body).to have_button('Create New Auth Token')
    end
  end
end
