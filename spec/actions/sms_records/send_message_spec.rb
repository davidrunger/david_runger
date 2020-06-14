# frozen_string_literal: true

RSpec.describe SmsRecords::SendMessage do
  subject(:send_message_action) { SmsRecords::SendMessage.new(sms_message_params) }

  let(:sms_message_params) do
    {
      user: user,
      message_type: message_type,
      message_params: message_params,
    }
  end
  let(:user) { users(:user) }
  let(:message_type) { 'grocery_store_items_needed' }
  let(:store) { user.stores.first! }
  let(:message_params) { { 'store_id' => store.id } }

  describe 'validations' do
    subject(:error_messages) do
      send_message_action.valid?
      send_message_action.errors.full_messages
    end

    describe 'validating that the user has a phone number' do
      let(:missing_phone_error) { "Phone can't be blank" }

      context 'when the user has a phone number' do
        before { expect(user.phone).to be_present }

        it 'does not have a validation error about a missing phone number' do
          expect(error_messages).not_to include(missing_phone_error)
        end
      end

      context 'when the user does not have a phone number' do
        before { user.update!(phone: nil) }

        it 'has a validation error about a missing phone number' do
          expect(error_messages).to include(missing_phone_error)
        end
      end
    end
  end

  describe '#log_message' do
    subject(:log_message) { send_message_action.send(:log_message) }

    it 'prints the message to STDOUT' do
      needed_item = store.items.needed.first!
      expect(send_message_action).to receive(:puts).with(<<~EXPECTED_LOG)
        NEXMO_API_KEY is blank; message would have been:
        ~~~~~~~~~~~~~~~~~~~~~
        == #{store.name}
        Notes: #{store.notes}
        - #{needed_item.name} (#{needed_item.needed})
        =====================
      EXPECTED_LOG

      log_message
    end
  end

  describe '#grocery_store_items_needed_message_body' do
    subject(:grocery_store_items_needed_message_body) do
      send_message_action.send(:grocery_store_items_needed_message_body)
    end

    let(:expected_message) do
      needed_items_list =
        store.items.needed.
          sort_by { |item| item.name.downcase }.
          map { |item| "- #{item.name} (#{item.needed})" }

      <<~EXPECTED_MESSAGE.rstrip
        == #{store.name}
        Notes: #{store.notes}
        #{needed_items_list.join("\n")}
      EXPECTED_MESSAGE
    end

    it 'includes the store name and items needed (name & quantity)' do
      expect(grocery_store_items_needed_message_body).to eq(expected_message)
    end
  end
end
