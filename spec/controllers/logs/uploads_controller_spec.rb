# frozen_string_literal: true

RSpec.describe Logs::UploadsController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#index' do
    subject(:get_index) { get(:index) }

    it 'renders a form to upload log entry data for a selected log and tips for usage' do
      get_index

      expect(response.body).to have_css('form select[name=log_id]')
      expect(response.body).to have_css('form input[type=file]')
      expect(response.body).to have_text('Recommended CSV columns')
    end
  end
end
