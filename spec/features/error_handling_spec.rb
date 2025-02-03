RSpec.describe 'Handling exceptions', :rack_test_driver do
  context 'when production-like error handling is in effect', :production_like_error_handling do
    context 'when exceptions_app is set to routes' do
      before { expect(Rails.application.config.exceptions_app).to eq(Rails.application.routes) }

      context 'when visiting a path that is not defined' do
        let(:nonexistent_path) { '/this-path-does-not-exist' }

        before do
          allow(Rails.logger).to receive(:warn)
        end

        it 'says that the page does not exist and returns a 404' do
          visit(nonexistent_path)
          expect(page).to have_text("The page you were looking for doesn't exist.")
          expect(page.status_code).to be(404)
          expect(Rails.logger).
            to have_received(:warn).
            with(%r{#{Regexp.escape(<<~WARN_LOG.squish)}})
              [error-report:warning] ActionController::RoutingError :
              No route matches [GET] "/this-path-does-not-exist" |
              handled=true source=application controller_action="errors#not_found"
            WARN_LOG
        end
      end

      context 'when a non-RoutingError is raised' do
        before do
          expect(BrowserSupportChecker).to receive(:new).and_raise(StandardError.new(error_message))

          # Don't actually write log messages for the error.
          allow(Rails.logger).to receive(:error)
          allow(Rails.logger).to receive(:add)
        end

        let(:error_message) { 'A BrowserSupportChecker instance could not be initialized!' }

        it 'renders the 500 error page, responds with 500, does not expose the error message, and logs an error' do
          visit(upgrade_browser_path)

          expect(page).to have_css('h1', text: 'Sorry, something went wrong.')
          expect(page.status_code).to be(500)
          expect(page).not_to have_text(error_message)
          expect(Rails.logger).to have_received(:error).with(<<~ERROR_LOG.squish)
            [error-report:error] StandardError : A BrowserSupportChecker
            instance could not be initialized! |
            handled=false source=application.action_dispatch
            controller_action="home#upgrade_browser"
          ERROR_LOG
          expect(Rails.logger).to have_received(:add).with(Logger::ERROR, /#{error_message}/)
        end
      end
    end
  end
end
