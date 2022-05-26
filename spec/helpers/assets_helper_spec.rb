# frozen_string_literal: true

RSpec.describe AssetsHelper do
  describe '#js_tag' do
    subject(:js_tag) { helper.js_tag(pack_name) }

    let(:pack_name) { 'home_app' }

    it 'returns a deferred script tag for a JavaScript file' do
      expect(js_tag).to match(
        %r{
          <
            script\s
            src="/vite/assets/home_app.[a-z0-9]{8}.js"\s
            type="module"\s
            defer="defer"
          ></script>
        }x,
      )
    end
  end
end
