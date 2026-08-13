RSpec.describe UserAgentDecoratable do
  let(:decorated_class) do
    Class.new do
      include UserAgentDecoratable

      attr_reader :user_agent

      def initialize(user_agent)
        @user_agent = user_agent
      end
    end
  end
  let(:decorated_object) { decorated_class.new(user_agent) }

  context 'when the browser is recognized' do
    let(:user_agent) do
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36'
    end

    it 'returns a readable description' do
      expect(decorated_object.pretty_user_agent).to include('Chrome')
    end
  end

  context 'when browser details are not recognized' do
    let(:user_agent) { 'Test browser' }

    it 'returns the original user agent' do
      expect(decorated_object.pretty_user_agent).to eq(user_agent)
    end
  end

  context 'when browser parsing raises an error' do
    let(:user_agent) { 'Test browser' }

    before { allow(Browser).to receive(:new).and_raise(StandardError) }

    it 'returns the original user agent' do
      expect(decorated_object.pretty_user_agent).to eq(user_agent)
    end
  end
end
