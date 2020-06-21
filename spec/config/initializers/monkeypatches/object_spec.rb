# frozen_string_literal: true

RSpec.describe Object do
  describe '#presence!' do
    subject(:presence!) { object.presence! }

    context 'when the object is blank' do
      let(:object) { nil }

      it 'raises an error' do
        expect { presence! }.to raise_error(StandardError, <<~ERROR.squish)
          Expected object to be `present?` but was nil
        ERROR
      end
    end

    context 'when the object is present' do
      let(:object) { true }

      it 'does not raise an error' do
        expect { presence! }.not_to raise_error
      end
    end
  end
end
