RSpec.describe CheckLinks::LaunchLinkChecksForPage do
  subject(:worker) { CheckLinks::LaunchLinkChecksForPage.new }

  describe '#perform' do
    subject(:perform) { worker.perform(url) }

    let(:url) { 'https://davidrunger.com/blog/using-vs-code-as-a-rails-app-update-merge-tool' }

    context 'when davidrunger.com returns a HEAD and GET requests for HTML with links' do
      let(:paths) { ['/relative_path', '#fragment', '#about'] }
      let(:urls) { ['https://davidrunger.com/groceries/', 'https://davidrunger.com/logs/'] }
      let(:links) { (paths + urls).shuffle }
      let(:links_as_html) do
        links.map do |link|
          %(<a href="#{link}">Link to #{link}</a>)
        end.join('')
      end

      before do
        stub_request(:head, url).
          to_return(
            status: 200,
            body: nil,
            headers: { 'Content-Type' => 'text/html; charset=UTF-8' },
          )

        stub_request(:get, url).
          to_return(
            status: 200,
            headers: {},
            body: <<~HTML)
              <!DOCTYPE html>
              <html lang="en">
              <head>
                <title>David Runger</title>
              </head>
              <body>
                #{links_as_html}
              </body>
              </html>
            HTML
      end

      it 'schedules jobs on the default queue for each davidrunger.com home page link' do
        expect {
          perform
        }.to change {
          Sidekiq::Queues['default'].size
        }.by(urls.size)
      end

      context 'when Rails.env is "development"', rails_env: :development do
        it 'does not raise an error' do
          expect { perform }.not_to raise_error
        end
      end
    end

    context 'when davidrunger.com returns a HEAD request indicating a non-HTML content type' do
      let(:url) { 'https://david-runger-public-uploads.s3.amazonaws.com/David-Runger-Resume.pdf' }
      let(:paths) { ['/relative_path', '#fragment', '#about'] }
      let(:urls) { ['https://davidrunger.com/groceries/', 'https://davidrunger.com/logs/'] }
      let(:links) { (paths + urls).shuffle }
      let(:links_as_html) do
        links.map do |link|
          %(<a href="#{link}">Link to #{link}</a>)
        end.join('')
      end

      before do
        stub_request(:head, url).
          to_return(status: 200, body: nil, headers: { 'Content-Type' => 'application/pdf' })
      end

      it 'does not enqueue any Sidekiq jobs' do
        expect { perform }.not_to enqueue_sidekiq_job
      end
    end
  end
end
