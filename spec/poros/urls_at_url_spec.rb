RSpec.describe UrlsAtUrl do
  subject(:urls_at_url) { UrlsAtUrl.new(page_url) }

  let(:page_url) { 'https://www.example.com/' }

  describe '#urls' do
    subject(:urls) { urls_at_url.urls }

    context 'when a request to the provided URL returns HTML with links' do
      before do
        stub_request(:get, 'https://www.example.com/').
          to_return(status: 200, body: <<~HTML, headers: {})
            <!doctype html>
            <html>
              <head></head>
              <body>
                <main>
                  <p>
                    <a href="https://www.google.com/">Google</a>
                    <a href="/groceries">Groceries</a>
                    <a>Link to nowhere</a>
                    <a href="https://davidrunger.com/">David Runger</a>
                  </p>
                </main>
              </body>
            </html>
          HTML
      end

      it 'returns a sorted array of the URLs linked in the page' do
        expect(urls).to eq([
          'https://davidrunger.com/',
          'https://www.google.com/',
        ])
      end
    end
  end

  describe '#url?' do
    subject(:url?) { urls_at_url.send(:url?, href) }

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
