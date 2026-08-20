RSpec.describe Capybara::ActionLogger do
  let(:session) { instance_double(Capybara::Session) }

  let(:capybara_dsl) do
    page = session
    Class.new do
      include Capybara::DSL

      define_method(:page) { page }
    end.new
  end

  describe 'Capybara DSL methods' do
    it 'logs their names and arguments before forwarding them to the current session' do
      expect(Rails.logger).to receive(:info).with(
        '[Capybara] find args=[".navigation"] kwargs={visible: false}',
      )
      expect(session).to receive(:find).with('.navigation', visible: false)

      capybara_dsl.find('.navigation', visible: false)
    end
  end
end
