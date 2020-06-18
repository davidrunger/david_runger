# frozen_string_literal: true

RSpec.describe 'Rack::Attack', :rack_test_driver do
  context 'when Rails cacheing is enabled/functional & Rack::Attack uses the Rails cache', :cache do
    around do |spec|
      original_rack_attack_store = Rack::Attack.cache.store
      expect(Rails.cache).to be_a(ActiveSupport::Cache::MemCacheStore)

      Rails.cache.clear
      Rack::Attack.cache.store = Rails.cache

      spec.run

      Rack::Attack.cache.store = original_rack_attack_store
      Rails.cache.clear
    end

    context 'when -- two times in one day -- a user requests paths with banned segments' do
      subject(:request_two_banned_paths) do
        visit('/wp')
        visit('/wordpress')
      end

      it 'bans the user from visiting any page' do
        expect {
          request_two_banned_paths
        }.to change {
          visit(root_path)
          page.status_code
        }.from(200).to(403)
      end
    end
  end
end
