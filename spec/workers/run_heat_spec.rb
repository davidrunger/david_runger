# frozen_string_literal: true

RSpec.describe RunHeat do
  subject(:worker) { RunHeat.new }

  describe '#perform' do
    subject(:perform) { worker.perform }

    context 'when the `disable_run_heat_worker` feature flag is disabled' do
      before do
        # https://github.com/aws/aws-sdk-ruby/issues/1371#issuecomment-269742397
        client_stub = Aws::S3::Client.new(stub_responses: true)
        expect(Aws::S3::Resource).
          to receive(:new).
          and_return(Aws::S3::Resource.new(client: client_stub))
      end

      around do |spec|
        ClimateControl.modify(S3_BUCKET: 'david-runger-uploads') do
          spec.run
        end
      end

      it 'downloads, zips, and uploads' do
        expect(worker).to receive(:system).with('bin/heat', exception: true)
        expect(worker).
          to receive(:system).with(%r{\Acd tmp/heat/images/ && zip -r \w+}, exception: true)
        # rubocop:disable RSpec/AnyInstance
        expect_any_instance_of(Aws::S3::Object).to receive(:upload_file)
        # rubocop:enable RSpec/AnyInstance

        perform
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
