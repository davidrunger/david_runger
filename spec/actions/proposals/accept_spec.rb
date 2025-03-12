RSpec.describe Proposals::Accept do
  subject(:action) do
    Proposals::Accept.new(
      encoded_token:
        JWT.encode(
          { proposer_id: proposer.id },
          ENV.fetch('JWT_SECRET'),
          'HS512',
        ),
      proposee:,
    )
  end

  let!(:proposer) { users(:user) }
  let!(:proposee) { User.where.missing(:marriage).except(proposer).first! }

  describe '#run' do
    subject(:run) { action.run }

    context 'when the proposer has deleted their marriage' do
      before { proposer&.marriage&.destroy! }

      it 'creates a new marriage with proposer and proposee as partners' do
        expect {
          run
        }.to change {
          proposer.reload.marriage
        }.from(nil).to(Marriage)
      end
    end
  end
end
