# frozen_string_literal: true

RSpec.describe 'Google site verification', :rack_test_driver do
  it 'responds with the Google site verification code' do
    visit('google83c07e1014ea4a70')

    expect(page.body).to eq('google-site-verification: google83c07e1014ea4a70.html')
  end
end
