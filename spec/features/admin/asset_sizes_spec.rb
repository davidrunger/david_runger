# frozen_string_literal: true

RSpec.describe 'Admin asset sizes' do
  subject(:visit_admin_asset_sizes) { visit('/admin/asset_sizes') }

  context 'when logged in as an AdminUser' do
    before { sign_in(admin_users(:admin_user), scope: :admin_user) }

    context 'when there is data about the size of an asset' do
      before do
        glob = TrackAssetSizes.all_globs.first
        PostgresTimeseries[glob].add(10)
        PostgresTimeseries[glob].add(16)
      end

      it 'renders a page with an "Asset Sizes" header and a canvas' do
        visit_admin_asset_sizes
        expect(page).to have_css('h2', text: 'Asset Sizes')
        expect(page).to have_css('canvas')
      end
    end
  end
end
