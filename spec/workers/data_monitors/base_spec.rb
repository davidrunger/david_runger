# frozen_string_literal: true

RSpec.describe DataMonitors::Base do
  subject(:data_monitor) { DataMonitors::Base.new }

  describe '#actual_satisfies_expectation?' do
    subject(:actual_satisfies_expectation?) do
      data_monitor.send(:actual_satisfies_expectation?, actual: actual, expected: expected)
    end

    context 'when expected is a range' do
      let(:expected) { 1..10 }

      context 'when actual falls in the range' do
        let(:actual) { 2.2 }

        specify { expect(actual_satisfies_expectation?).to eq(true) }
      end

      context 'when actual falls outside of the range' do
        let(:actual) { 22 }

        specify { expect(actual_satisfies_expectation?).to eq(false) }
      end
    end

    context 'when expected is an array of strings' do
      let(:expected) { %w[aardvark bison] }

      context 'when actual equals the expected array' do
        let(:actual) { expected.deep_dup }

        specify { expect(actual_satisfies_expectation?).to eq(true) }
      end

      context 'when actual does not equal the expected array' do
        let(:actual) { expected.reverse }

        specify { expect(actual_satisfies_expectation?).to eq(false) }
      end
    end
  end
end
