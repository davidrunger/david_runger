RSpec.describe TrackAssetSizes do
  subject(:worker) { TrackAssetSizes.new }

  describe '#perform' do
    subject(:perform) { worker.perform }

    context 'when "public/vite/.vite/manifest.json" contains a JSON asset manifest' do
      before do
        expect(File).to receive(:read).with('public/vite/.vite/manifest.json').and_return(<<~JSON)
          {
            "entrypoints/groceries_app.ts": {
              "file": "assets/groceries_app.e736a509.js",
              "src": "entrypoints/groceries_app.ts",
              "isEntry": true,
              "imports": [
                "_modal_store.c843ae02.js",
                "_lodash.4ea7f2dc.js"
              ],
              "css": [
                "assets/groceries_app.00fba040.css"
              ],
              "assets": [
                "assets/beach-background.93ff8fcc.webp"
              ]
            },
            "__commonjsHelpers.b8add541.js": {
              "file": "assets/_commonjsHelpers.b8add541.js"
            },
            "_modal_store.c843ae02.js": {
              "file": "assets/modal_store.c843ae02.js",
              "imports": [
                "_lodash.4ea7f2dc.js",
                "__commonjsHelpers.b8add541.js"
              ],
              "css": [
                "assets/modal_store.921deda9.css"
              ]
            },
            "_lodash.4ea7f2dc.js": {
              "file": "assets/lodash.4ea7f2dc.js",
              "imports": [
                "__commonjsHelpers.b8add541.js"
              ]
            }
          }
        JSON
      end

      context 'when File sizes are returned' do
        before do
          allow(File).to receive(:new).with('public/vite/assets/groceries_app.e736a509.js').
            and_return(instance_double(File, size: 10))
          allow(File).to receive(:new).with('public/vite/assets/modal_store.c843ae02.js').
            and_return(instance_double(File, size: 20))
          allow(File).to receive(:new).with('public/vite/assets/lodash.4ea7f2dc.js').
            and_return(instance_double(File, size: 30))
          allow(File).to receive(:new).with('public/vite/assets/_commonjsHelpers.b8add541.js').
            and_return(instance_double(File, size: 40))
          allow(File).to receive(:new).with('public/vite/assets/groceries_app.00fba040.css').
            and_return(instance_double(File, size: 50))
          allow(File).to receive(:new).with('public/vite/assets/modal_store.921deda9.css').
            and_return(instance_double(File, size: 60))
        end

        it 'stores the JS asset size(s) in Redis', :frozen_time do
          expect {
            perform
          }.to change {
            Timeseries['groceries*.js'].to_h
          }.from({}).
            to({ Time.current => 100 })
        end

        it 'stores the CSS asset size(s) in Redis', :frozen_time do
          expect {
            perform
          }.to change {
            Timeseries['groceries*.css'].to_h
          }.from({}).
            to({ Time.current => 110 })
        end
      end
    end
  end
end
