# frozen_string_literal: true

RSpec.describe 'Handling exceptions', :rack_test_driver do
  context 'when the show_exceptions Rails configuration is `true`' do
    around do |spec|
      original_show_exceptions_setting = Rails.configuration.action_dispatch.show_exceptions
      Rails.configuration.action_dispatch.show_exceptions = true
      spec.run
      Rails.configuration.action_dispatch.show_exceptions = original_show_exceptions_setting
    end

    context 'when visiting a path that is not defined' do
      let(:nonexistent_path) { '/this-path-does-not-exist' }

      it 'renders info about the routing error' do
        visit(nonexistent_path)
        expect(page).to have_text(%(No route matches [GET] "#{nonexistent_path}"))
      end
    end

    context 'when a non-RoutingError is raised' do
      before do
        expect(BrowserSupportChecker).to receive(:new).and_raise(StandardError.new(error_message))
      end

      let(:error_message) { 'Something went wrong!' }

      it 'renders info about that error' do
        visit(upgrade_browser_path)
        expect(page).to have_css('h2', text: error_message)
      end
    end
  end
end
