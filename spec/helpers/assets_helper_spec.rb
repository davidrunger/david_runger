# frozen_string_literal: true

RSpec.describe AssetsHelper do
  describe '#ts_tag' do
    subject(:ts_tag) { helper.ts_tag(pack_name) }

    let(:pack_name) { 'home_app' }

    it 'returns a deferred script tag for a JavaScript file' do
      expect(ts_tag).to match(
        %r{
          <
            script\s
            src="/vite/assets/home_app-\w{8}\.js"\s
            type="module"\s
            defer="defer"
          ></script>
        }x,
      )
    end
  end
end
