# frozen_string_literal: true

RSpec.describe(ApplicationCable::Channel) do
  subject(:channel) { ApplicationCable::Channel.new(connection, :current_user) }

  let(:connection) do
    ApplicationCable::Connection.new(
      ActionCable::Server::Base.new,
      { 'warden' => warden },
    )
  end
  let(:warden) { instance_double(Warden::Proxy, user:) }

  before { connection.connect }

  describe '#authorize!' do
    subject(:authorize!) { channel.authorize!(record, policy_query) }

    let(:record) { log }
    let(:log) { Log.first! }
    let(:policy_query) { :show? }

    context 'when there is a current_user' do
      let(:user) { User.where.not(id: record.user_id).first! }

      context 'when the user is not authorized to view the record' do
        before { log.log_shares.find_each(&:destroy!) }

        it 'raises an error with an error message including "User:<user id>"' do
          expect { authorize! }.to raise_error(
            Pundit::NotAuthorizedError,
            "LogPolicy says that User:#{user.id} is not authorized to show? Log:#{log.id}",
          )
        end
      end

      context 'when the user is authorized to view the record' do
        let(:user) { record.user }

        it 'does not raise an error' do
          expect { authorize! }.not_to raise_error
        end
      end
    end
  end
end
