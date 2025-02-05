RSpec.describe Admin::DeploysController do
  context 'when logged in as an AdminUser' do
    before { sign_in(admin_users(:admin_user)) }

    context 'when there are at least two Deploys' do
      before do
        (2 - Deploy.count).times do
          create(:deploy)
        end
      end

      let(:most_recent_deploys) { Deploy.reorder(:created_at).last(2) }
      let(:most_recent_deploy) { most_recent_deploys.last }
      let(:second_most_recent_deploy) { most_recent_deploys.first }

      describe '#index' do
        subject(:get_index) { get(:index) }

        it 'lists deploys with commit and compare GitHub links' do
          get_index

          expect(response).to have_http_status(200)

          Deploy.all.presence!.each do |deploy|
            expect(response.body).to have_link(
              deploy.git_sha,
              href: "https://github.com/davidrunger/david_runger/commit/#{deploy.git_sha}",
            )
          end

          expect(Nokogiri::HTML5(response.body).at_css('table tbody tr:first')).to have_link(
            "#{second_most_recent_deploy.git_sha.first(8)}...#{most_recent_deploy.git_sha.first(8)}",
            href:
              'https://github.com/davidrunger/david_runger/compare/' \
              "#{second_most_recent_deploy.git_sha.first(8)}...#{most_recent_deploy.git_sha.first(8)}",
          )
        end
      end

      describe '#show' do
        subject(:get_show) { get(:show, params: { id: deploy.id }) }

        let(:deploy) { most_recent_deploy }

        it 'responds with 200 and provides commit and compare GitHub links' do
          get_show

          expect(response).to have_http_status(200)

          expect(response.body).to have_link(
            deploy.git_sha,
            href: "https://github.com/davidrunger/david_runger/commit/#{deploy.git_sha}",
          )

          expect(response.body).to have_link(
            "#{second_most_recent_deploy.git_sha.first(8)}...#{most_recent_deploy.git_sha.first(8)}",
            href:
              'https://github.com/davidrunger/david_runger/compare/' \
              "#{second_most_recent_deploy.git_sha.first(8)}...#{most_recent_deploy.git_sha.first(8)}",
          )
        end
      end
    end
  end
end
