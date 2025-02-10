RSpec.describe 'Rack::Attack', :rack_test_driver do
  context 'when Rails caching is enabled/functional & Rack::Attack uses the Rails cache', :cache do
    around do |spec|
      original_rack_attack_store = Rack::Attack.cache.store
      expect(Rails.cache).to be_a(ActiveSupport::Cache::MemoryStore)

      Rails.cache.clear
      Rack::Attack.cache.store = Rails.cache

      spec.run
    ensure
      Rack::Attack.cache.store = original_rack_attack_store
      Rails.cache.clear
    end

    context 'when -- two times in one day -- a user requests paths with banned segments' do
      subject(:request_two_banned_paths) do
        visit(banned_path_1)
        visit(banned_path_2)
      end

      let(:banned_path_1) { "something.#{BannedPathFragment.first!.value}7" }
      let(:banned_path_2) { BannedPathFragment.second!.value }

      it 'bans the user from visiting any page', :prerendering_disabled do
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
