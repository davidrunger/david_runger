RSpec.describe 'Git SHA endpoint', :rack_test_driver do
  subject(:visit_git_sha_path) { visit('/sha') }

  context 'when a GIT_REV env var is present' do
    around do |spec|
      ClimateControl.modify(GIT_REV: git_sha) do
        spec.run
      end
    end

    let(:git_sha) { 'b18d253eab03e0eb8d7f7dc995ececd326ad9fd5' }

    it 'renders the first 8 characters of the Git SHA' do
      visit_git_sha_path

      expect(page.text).to eq(git_sha.first(8))
    end
  end
end
