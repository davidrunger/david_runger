# frozen_string_literal: true

RSpec.describe JavascriptHelper do
  describe '#js_tag' do
    subject(:js_tag) { helper.js_tag(pack_name) }

    let(:pack_name) { 'home_app' }

    context 'when the Rails env is "test"', rails_env: :test do
      it 'returns a deferred script tag for a webpack asset' do
        expect(js_tag).to eq('<script src="/packs-test/home_app.js" defer="defer"></script>')
      end
    end

    context 'when the Rails env is "development"', rails_env: :development do
      it 'tries to return a vite script tag' do # (but fails because vite isn't in the test bundle)
        expect { js_tag }.to raise_error(/undefined method `vite_javascript_tag'/)
      end
    end
  end
end
