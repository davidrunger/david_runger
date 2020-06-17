# frozen_string_literal: true

RSpec.describe CreateIpBlock do
  subject(:worker) { CreateIpBlock.new }

  describe '#perform' do
    subject(:perform) { worker.perform(ip) }

    let(:ip) { Faker::Internet.public_ip_v4_address }

    context 'when there is already an IpBlock with the specified IP' do
      before { create(:ip_block, ip: ip) }

      it 'does not create a new IpBlock or raise an error' do
        expect { perform }.not_to change { IpBlock.count }
      end
    end

    context 'when there is not yet an IpBlock with the specified IP' do
      before { IpBlock.where(ip: ip).find_each(&:destroy!) }

      context 'when there is data in Redis about the previously blocked requests of the IP' do
        before do
          IpBlocks::StoreRequestBlockInRedis.new(ip: ip, path: blocked_path_1).run
          IpBlocks::StoreRequestBlockInRedis.new(ip: ip, path: blocked_path_2).run
        end

        let(:blocked_path_1) { '/wp' }
        let(:blocked_path_2) { '/wordpress' }

        it 'creates a new IpBlock with the specified IP & reason mentioning the blocked paths' do
          expect { perform }.to change { IpBlock.count }.by(1)
          last_block = IpBlock.order(:created_at).last!
          expect(last_block.ip).to eq(ip)
          expect(last_block.reason).to match(
            %r{#{blocked_path_1} \(at .+\)\n#{blocked_path_2} \(at .+\)},
          )
        end
      end
    end
  end
end
