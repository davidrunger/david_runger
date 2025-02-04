RSpec.describe Admin::DeploysController do
  context 'when logged in as an AdminUser' do
    before { sign_in(admin_users(:admin_user)) }

    describe '#index' do
      subject(:get_index) { get(:index) }

      it 'lists deploys with the commit SHA as a GitHub link' do
        get_index

        expect(response).to have_http_status(200)

        Deploy.all.presence!.each do |deploy|
          expect(response.body).to have_link(
            deploy.git_sha,
            href: "https://github.com/davidrunger/david_runger/commit/#{deploy.git_sha}",
          )
        end
      end
    end

    describe '#show' do
      subject(:get_show) { get(:show, params: { id: deploy.id }) }

      let(:deploy) { deploys(:deploy) }

      it 'responds with 200 and links to the commit on GitHub' do
        get_show

        expect(response).to have_http_status(200)

        expect(response.body).to have_link(
          deploy.git_sha,
          href: "https://github.com/davidrunger/david_runger/commit/#{deploy.git_sha}",
        )
      end
    end
  end
end
