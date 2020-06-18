# frozen_string_literal: true

RSpec.describe 'Handling exceptions', :rack_test_driver do
  context 'when production-like error handling is in effect', :production_like_error_handling do
    context 'when visiting a path that is not defined' do
      let(:nonexistent_path) { '/this-path-does-not-exist' }

      it 'says that the page does not exist and returns a 404' do
        visit(nonexistent_path)
        expect(page).to have_text("The page you were looking for doesn't exist.")
        expect(page.status_code).to be(404)
      end
    end

    context 'when a non-RoutingError is raised' do
      before do
        expect(BrowserSupportChecker).to receive(:new).and_raise(StandardError.new(error_message))
      end

      let(:error_message) { 'A BrowserSupportChecker instance could not be initialized!' }

      it 'renders the 500 error page and responds with 500' do
        visit(upgrade_browser_path)
        expect(page).to have_css('h1', text: 'Sorry, something went wrong.')
        expect(page.status_code).to be(500)
      end

      it 'does not expose the error message' do
        visit(upgrade_browser_path)
        expect(page).not_to have_text(error_message)
      end
    end
  end
end
