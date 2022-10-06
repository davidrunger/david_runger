# frozen_string_literal: true

RSpec.describe ActiveStorage::Service::NamespacedS3Service do
  subject(:service) do
    ActiveStorage::Service::NamespacedS3Service.new(
      bucket: 'test-bucket',
      namespace:,
      region: 'us-east-1',
    )
  end

  let(:namespace) { 'active_storage_uploads' }

  describe '#object_for' do
    subject(:object_for) { service.send(:object_for, filename) }

    let(:filename) { 'aeu83hau.eml' }

    it 'returns an object with a namespaced file path' do
      expect(object_for.key).to eq("#{namespace}/#{filename}")
    end
  end
end
