# frozen_string_literal: true

RSpec.describe TouchActivityAt do
  subject(:worker) { TouchActivityAt.new }

  describe '#perform' do
    subject(:perform) { worker.perform(user_id, Float(request_time)) }

    let(:request_time) { Time.current }

    context 'when there is no user with the provided `user_id`' do
      let(:user_id) { User.maximum(:id) + 1 }

      it 'logs a message noting that no such user can be found' do
        expect(Rails.logger).to receive(:info).
          with(/User #{user_id} was not found/).
          and_call_original

        perform
      end
    end

    context 'when there is a user with the provided `user_id`' do
      let(:user_id) { user.id }
      let(:user) { users(:user) }

      context "when the user's `last_activity_at` is nil" do
        before { user.update!(last_activity_at: nil) }

        it "updates the user's `last_activity_at` to the request time" do
          expect {
            perform
          }.to change {
            user.reload.last_activity_at&.to_i # use to_i to ignore issues with microsecond rounding
          }.from(nil).
            to(Integer(request_time))
        end
      end
    end
  end
end
