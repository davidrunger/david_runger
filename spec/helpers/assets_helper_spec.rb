RSpec.describe AssetsHelper do
  describe '#admin_ts_tag' do
    subject(:admin_ts_tag) { helper.admin_ts_tag(entrypoint_name) }

    let(:entrypoint_name) { 'active_admin' }

    context 'when Rails.env is "development"', rails_env: :development do
      context 'when VITE_RUBY_ENTRYPOINTS_DIR and VITE_RUBY_PUBLIC_OUTPUT_DIR are set to admin values' do
        around do |spec|
          ClimateControl.modify(
            VITE_RUBY_ENTRYPOINTS_DIR: 'admin_entrypoints',
            VITE_RUBY_PUBLIC_OUTPUT_DIR: 'vite-admin',
          ) do
            spec.run
          end
        end

        context 'when a request to "http://localhost:3036/vite-admin/admin_entrypoints/#{entrypoint_name}.ts" returns 200' do
          before do
            stub_request(
              :get,
              "http://localhost:3036/vite-admin/admin_entrypoints/#{entrypoint_name}.ts",
            ).to_return(status: 200, headers: {}, body: '')
          end

          context 'when #vite_typescript_tag returns a value for the entrypoint' do
            before do
              allow(helper).
                to receive(:vite_typescript_tag).
                with(entrypoint_name, defer: 'defer', crossorigin: nil).
                and_return(stubbed_vite_typescript_tag)
            end

            let(:stubbed_vite_typescript_tag) { '<script></script><style></style>' }

            it 'returns a vite_typescript_tag (which will also include a style tag, if appropriate)' do
              expect(admin_ts_tag).to eq(stubbed_vite_typescript_tag)
            end
          end
        end
      end
    end
  end

  describe '#ts_tag' do
    subject(:ts_tag) { helper.ts_tag(pack_name) }

    let(:pack_name) { 'home_app' }

    it 'returns a deferred script tag for a JavaScript file' do
      expect(ts_tag).to match(
        %r{
          <
            script\s
            src="/vite/assets/home_app-[\w-]{8}\.js"\s
            type="module"\s
            defer="defer"
          ></script>
        }x,
      )
    end
  end
end
