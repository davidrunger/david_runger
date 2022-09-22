# frozen_string_literal: true

RSpec.describe 'site ownership verification', :rack_test_driver do
  describe 'Google' do
    it 'responds with the Google site verification code' do
      visit('google83c07e1014ea4a70')

      expect(page.body).to eq('google-site-verification: google83c07e1014ea4a70.html')
    end
  end

  describe 'detectify' do
    it 'responds with the detectify site verification code' do
      visit('7ee411f3bc50160c876708bdda166787.txt')

      expect(page.body).to eq('detectify')
    end
  end
end
