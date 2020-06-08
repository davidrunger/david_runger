# frozen_string_literal: true

RSpec.describe 'Logs app' do
  let(:user) { users(:user) }

  context 'when user is signed in' do
    before { sign_in(user) }

    it 'renders the logs app', :js do
      visit logs_path

      expect(page).to have_text(user.email)
      user.logs.pluck(:name).presence!.each do |log_name|
        expect(page).to have_text(log_name)
      end
      expect(page).to have_text('Create new log')
    end
  end
end
