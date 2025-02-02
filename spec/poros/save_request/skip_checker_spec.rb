RSpec.describe SaveRequest::SkipChecker do
  subject(:skip_checker) { described_class.new(params:) }

  describe '#initialize' do
    subject(:call_initialize) { skip_checker }

    context 'when params does not include a controller' do
      let(:params) { { 'action' => 'index' } }

      it 'raises an error' do
        expect { call_initialize }.to raise_error(PresenceBangMonkeypatch::ObjectNotPresent)
      end
    end

    context 'when params does not include an action' do
      let(:params) { { 'controller' => 'home' } }

      it 'raises an error' do
        expect { call_initialize }.to raise_error(PresenceBangMonkeypatch::ObjectNotPresent)
      end
    end

    context 'when params includes a controller and action' do
      let(:params) { { 'controller' => 'home', 'action' => 'index' } }

      it 'does not raise an error' do
        expect { call_initialize }.not_to raise_error
      end
    end
  end

  describe '#skip?' do
    subject(:skip?) { skip_checker.skip? }

    context 'when the controller is health_checks' do
      let(:params) { { 'controller' => 'health_checks', 'action' => 'anything' } }

      it 'returns true' do
        expect(skip?).to eq(true)
      end
    end

    context 'when the controller is anonymous' do
      let(:params) { { 'controller' => 'anonymous', 'action' => 'anything' } }

      it 'returns true' do
        expect(skip?).to eq(true)
      end
    end

    context 'when the controller is blog and the action is assets' do
      let(:params) { { 'controller' => 'blog', 'action' => 'assets' } }

      it 'returns true' do
        expect(skip?).to eq(true)
      end
    end

    context 'when the controller is api/events and the action is create' do
      let(:params) { { 'controller' => 'api/events', 'action' => 'create' } }

      it 'returns true' do
        expect(skip?).to eq(true)
      end
    end

    context 'when uptime_robot is among the params keys' do
      let(:params) { { 'controller' => 'home', 'action' => 'index', 'uptime_robot' => '1' } }

      it 'returns true' do
        expect(skip?).to eq(true)
      end
    end

    context 'when controller is home, action is index, and params does not include uptime_robot' do
      let(:params) { { 'controller' => 'home', 'action' => 'index', 'a_query_param' => 'true' } }

      it 'returns true' do
        expect(skip?).to eq(false)
      end
    end
  end
end
