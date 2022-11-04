# frozen_string_literal: true

RSpec.describe CheckHomeLinks::Launcher do
  subject(:worker) { CheckHomeLinks::Launcher.new }

  describe '#perform' do
    subject(:perform) { worker.perform }

    context 'when davidrunger.com returns HTML with links' do
      let(:paths) { ['/relative_path', '#fragment', '#about'] }
      let(:urls) { ['https://davidrunger.com/groceries/', 'https://davidrunger.com/logs/'] }
      let(:links) { (paths + urls).shuffle }
      let(:links_as_html) do
        links.map do |link|
          %(<a href="#{link}">Link to #{link}</a>)
        end.join('')
      end

      before do
        stub_request(:get, 'https://davidrunger.com/').
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
  end

  describe '#url?' do
    subject(:url?) { worker.send(:url?, href) }

    context 'when the href is a relative path' do
      let(:href) { '/groceries' }

      specify { expect(url?).to eq(false) }
    end

    context 'when the href is a fragment' do
      let(:href) { '#about' }

      specify { expect(url?).to eq(false) }
    end

    context 'when the href is an http URL' do
      let(:href) { 'http://www.google.com/' }

      specify { expect(url?).to eq(true) }
    end

    context 'when the href is an https URL' do
      let(:href) { 'https://www.google.com/' }

      specify { expect(url?).to eq(true) }
    end

    context 'when the href is a URL beginning with //' do
      let(:href) { '//www.google.com/' }

      specify { expect(url?).to eq(true) }
    end
  end
end
