# frozen_string_literal: true

RSpec.describe InvalidRecordsChecker do
  subject(:worker) { InvalidRecordsChecker.new }

  describe '#perform' do
    subject(:perform) { worker.perform }

    context 'when there is at least one invalid record in the database' do
      before do
        # rubocop:disable Rails/SkipsModelValidations
        user = User.first!
        # this "phone number" violates the `format` regex validation for User#phone
        user.update_columns(phone: 'this is not a phone number')
        # rubocop:enable Rails/SkipsModelValidations
        expect(user).not_to be_valid
      end

      it 'enqueues an email', queue_adapter: :test do
        expect { perform }.
          to enqueue_mail(InvalidRecordsMailer, :invalid_records).
          with(args: [hash_including('User' => Integer)])
      end
    end
  end
end
