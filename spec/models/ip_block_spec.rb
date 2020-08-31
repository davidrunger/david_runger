# frozen_string_literal: true

RSpec.describe IpBlock, type: :model do
  subject(:ip_block) { IpBlock.new }

  it { is_expected.to validate_presence_of(:ip) }

  context 'when the IP address is an IPv6 format' do
    before { ip_block.ip = Faker::Internet.ip_v6_address }

    it 'is valid' do
      expect(ip_block).to be_valid
    end
  end
end
