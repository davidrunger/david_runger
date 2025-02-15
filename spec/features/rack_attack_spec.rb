RSpec.describe 'Rack::Attack', :rack_test_driver do
  context 'when Rails caching is enabled/functional & Rack::Attack uses the Rails cache', :cache do
    around do |spec|
      expect(Rails.cache).to be_a(ActiveSupport::Cache::MemoryStore)

      Rack::Attack.cache.with(store: Rails.cache) do
        spec.run
      end
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
          visit(up_path)
          page.status_code
        }.from(200).to(403)
      end
    end
  end
end
