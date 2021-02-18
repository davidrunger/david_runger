# frozen_string_literal: true

RSpec.describe InvalidRecordsCheck::Checker do
  subject(:worker) { InvalidRecordsCheck::Checker.new }

  describe '#perform' do
    subject(:perform) { worker.perform(klass_name) }

    let(:klass_name) { 'User' }

    context 'when there is at least one invalid record of the specified class' do
      before do
        user = User.first!
        # this "phone number" violates the `format` regex validation for User#phone
        # rubocop:disable Rails/SkipsModelValidations
        user.update_columns(phone: 'this is not a phone number')
        # rubocop:enable Rails/SkipsModelValidations
        expect(user).not_to be_valid
      end

      it 'enqueues an email', queue_adapter: :test do
        expect { perform }.
          to enqueue_mail(InvalidRecordsMailer, :invalid_records).
          with(args: ['User', 1])
      end
    end

    context 'when checking `QuizQuestionAnswerSelection`' do
      let(:klass_name) { 'QuizQuestionAnswerSelection' }

      context 'when there are multiple `QuizQuestionAnswerSelection`s' do
        before { expect(QuizQuestionAnswerSelection.count).to be >= 2 }

        it 'does not raise an error' do
          expect { perform }.not_to raise_error
        end
      end
    end
  end
end
