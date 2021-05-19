# frozen_string_literal: true

RSpec.describe VoicemailsMailbox do
  let(:to_email) { "voicemails|auth-secret/#{auth_token_secret}@mg.davidrunger.com" }
  let(:from_email) { user.email }
  let(:user) { users(:user) }
  let(:auth_token) { user.auth_tokens.first! }
  let(:auth_token_secret) { auth_token.secret }
  let(:concise_email_subject) { "New voicemail from #{Faker::Name.name}" }
  let(:full_email_subject) { "Fwd: #{concise_email_subject}" }
  let(:actual_message_content) do
    <<~ACTUAL_MESSAGE_CONTENT.squish
      Hey, is it satisfying I found really cold right now? Probably walking home from going to the
      bank. Can you call back if you have time, but nothing in particular. Just wanted to say hi.
      Hope you have a good night. I'll talk to you later. Bye.
    ACTUAL_MESSAGE_CONTENT
  end
  let(:email_body) do
    <<~EMAIL_BODY.squish
      [image: Google Voice] <https://voice.google.com>
      #{actual_message_content}
      play message <https://www.google.com/voice/fm/2342344SKeCW>
    EMAIL_BODY
  end

  describe 'routing' do
    it 'routes email to the mailbox' do
      expect(VoicemailsMailbox).to receive_email(to: to_email)
    end
  end

  describe 'processing' do
    # rubocop:disable RSpec/EmptyLineAfterSubject, RSpec/MultipleSubjects
    subject(:process_mail) { process(mail) }
    subject(:processed_mail) { process_mail }
    # rubocop:enable RSpec/EmptyLineAfterSubject, RSpec/MultipleSubjects

    let(:mail) do
      Mail.new(
        to: to_email,
        from: from_email,
        subject: full_email_subject,
        body: email_body,
      )
    end

    context 'when there is no AuthToken matching the secret in the `To` address' do
      let(:auth_token_secret) { SecureRandom.uuid }

      it 'does not raise an error' do
        expect { process_mail }.not_to raise_error
      end

      it 'logs that no AuthToken was found' do
        expect(Rails.logger).to receive(:info).
          exactly(:once).
          with("No AuthToken could be found for email with subject '#{full_email_subject}'")
        expect(Rails.logger).to receive(:info).at_least(:once).and_call_original # pass other calls

        process_mail
      end

      it 'does not send a text message' do
        expect(NexmoClient).not_to receive(:send_text!)
        process_mail
      end
    end

    context 'when there is no voicemail message content' do
      let(:actual_message_content) { '' }

      it 'does not raise an error' do
        expect { process_mail }.not_to raise_error
      end

      it 'logs that no voicemail message content was found' do
        expect(Rails.logger).to receive(:info).
          exactly(:once).
          with("No voicemail message was found in email with subject '#{full_email_subject}'")
        expect(Rails.logger).to receive(:info).at_least(:once).and_call_original # pass other calls

        process_mail
      end

      it 'does not send a text message' do
        expect(NexmoClient).not_to receive(:send_text!)
        process_mail
      end
    end

    context 'when the relevant NEXMO ENV variables are set' do
      around do |spec|
        ClimateControl.modify(
          NEXMO_PHONE_NUMBER: '11235551234',
          NEXMO_API_KEY: 'DEFabc123',
          NEXMO_API_SECRET: '183726ea',
        ) do
          spec.run
        end
      end

      context 'when sending the message via Nexmo succeeds' do
        let!(:stubbed_venmo_post_success) do
          VendorTestApi::Nexmo.stub_post_success(message_content: expected_message_content)
        end
        let(:expected_message_content) do
          <<~EXPECTED_MESSAGE_CONTENT.rstrip
            #{concise_email_subject}:
            #{actual_message_content}
          EXPECTED_MESSAGE_CONTENT
        end

        it 'marks email as delivered' do
          expect(processed_mail).to have_been_delivered
        end

        it 'sends a text message via the Venmo API' do
          process_mail
          expect(stubbed_venmo_post_success).to have_been_requested
        end
      end
    end

    context 'when an error occurs sending the SMS message' do
      before do
        # rubocop:disable RSpec/AnyInstance
        expect_any_instance_of(SmsRecords::SendMessage).
          to receive(:run!).
          and_raise(raised_error)
        # rubocop:enable RSpec/AnyInstance
      end

      let(:raised_error) { StandardError.new('Problem sending message!') }

      it 'rescues the error and sends it to Rollbar' do
        expect(Rollbar).
          to receive(:error).
          with(
            raised_error,
            user_id: Integer,
            subject: String,
            voicemail_message_content: String,
          )

        expect { process_mail }.not_to raise_error
      end
    end
  end
end
