# frozen_string_literal: true

RSpec.describe RunHeat do
  subject(:worker) { RunHeat.new }

  describe '#perform' do
    subject(:perform) { worker.perform }

    context 'when the `disable_run_heat_worker` feature flag is disabled' do
      before do
        expect(Flipper.enabled?(:disable_run_heat_worker)).to eq(false)

        # https://github.com/aws/aws-sdk-ruby/issues/1371#issuecomment-269742397
        client_stub = Aws::S3::Client.new(stub_responses: true)
        allow(Aws::S3::Resource).
          to receive(:new).
          and_return(Aws::S3::Resource.new(client: client_stub))

        expect(worker).to receive(:system).with('bin/heat -n 32', exception: true)
      end

      around do |spec|
        ClimateControl.modify(S3_BUCKET: 'david-runger-development-uploads') do
          spec.run
        end
      end

      context 'when the images directory is empty after running bin/heat' do
        before { expect(Dir).to receive(:empty?).with('tmp/heat/images/').and_return(true) }

        it 'does not attempt to zip (or upload)' do
          expect(worker).not_to receive(:system).with(/zip/)
          # rubocop:disable RSpec/AnyInstance
          expect_any_instance_of(Aws::S3::Object).not_to receive(:upload_file)
          # rubocop:enable RSpec/AnyInstance

          perform
        end
      end

      context 'when the images directory is not empty after running bin/heat' do
        before { expect(Dir).to receive(:empty?).with('tmp/heat/images/').and_return(false) }

        it 'zips and uploads' do
          expect(worker).
            to receive(:system).
            with(%r{\Acd tmp/heat/images/ && zip -r \w+}, exception: true)
          # rubocop:disable RSpec/AnyInstance
          expect_any_instance_of(Aws::S3::Object).to receive(:upload_file)
          # rubocop:enable RSpec/AnyInstance

          perform
        end
      end
    end

    context 'when the `disable_run_heat_worker` feature flag is enabled' do
      before { activate_feature!(:disable_run_heat_worker) }

      it 'does not execute any system commands' do
        expect(worker).not_to receive(:system)

        perform
      end
    end
  end
end
