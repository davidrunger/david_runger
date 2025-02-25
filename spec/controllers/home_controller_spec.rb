RSpec.describe HomeController do
  describe '#home', :prerendering_disabled do
    subject(:get_index) { get(:index) }

    it 'includes window data data' do
      get_index

      expect(response.body).to include('window.davidrunger = ')
    end
  end

  describe '#upgrade_browser' do
    subject(:get_upgrade_browser) { get(:upgrade_browser) }

    context 'when using a supported browser' do
      let(:firefox_72_user_agent) do
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:72.0) Gecko/20100101 Firefox/72.0'
      end

      before do
        request.headers['User-Agent'] = firefox_72_user_agent

        browser = Browser.new(firefox_72_user_agent)
        expect(browser.name).to eq('Firefox')
        expect(browser.version).to eq('72')
        expect(BrowserSupportChecker.new(browser)).to be_supported
      end

      it 'redirects to the root path' do
        expect(get_upgrade_browser).to redirect_to(root_path)
      end
    end
  end
end
