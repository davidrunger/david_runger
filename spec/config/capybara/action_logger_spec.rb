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
      allow(Rails.logger).to receive(:info).with(
        '[Capybara] find args=[".navigation"] kwargs={visible: false}',
      )
      allow(session).to receive(:find).with('.navigation', visible: false)

      capybara_dsl.find('.navigation', visible: false)

      expect(Rails.logger).to have_received(:info).once.with(
        '[Capybara] find args=[".navigation"] kwargs={visible: false}',
      )
      expect(session).to have_received(:find).once.with('.navigation', visible: false)
    end

    it 'logs Capybara nodes without inspecting them' do
      node = Capybara::Node::Element.allocate

      allow(Rails.logger).to receive(:info).with(
        '[Capybara] within args=[#<Capybara::Node::Element>] kwargs={}',
      )
      allow(session).to receive(:within).with(node)

      capybara_dsl.within(node)

      expect(Rails.logger).to have_received(:info).once.with(
        '[Capybara] within args=[#<Capybara::Node::Element>] kwargs={}',
      )
      expect(session).to have_received(:within).once.with(node)
    end
  end
end
