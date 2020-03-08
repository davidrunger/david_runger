# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BlankParamsAsNil do
  using BlankParamsAsNil

  subject(:params) { ActionController::Parameters.new(params_hash) }

  let(:params_hash) do
    {
      empty_string_param: '',
      empty_array_param: [],
      nonempty_string_param: 'David Runger',
      nonempty_array_param: [1, 2, 3],
    }
  end

  describe '#blank_params_as_nil' do
    subject(:blank_params_as_nil) { params.blank_params_as_nil(params_hash.keys.map(&:to_s)) }

    it 'transforms an empty string param to nil' do
      expect(blank_params_as_nil[:empty_string_param]).to eq(nil)
    end

    it 'transforms an empty array param to nil' do
      expect(blank_params_as_nil[:empty_array_param]).to eq(nil)
    end

    it 'does not change a non-empty string param' do
      expect(blank_params_as_nil[:nonempty_string_param]).to eq('David Runger')
    end

    it 'does not change a non-empty array param' do
      expect(blank_params_as_nil[:nonempty_array_param]).to eq([1, 2, 3])
    end
  end
end
