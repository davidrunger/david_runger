# frozen_string_literal: true

RSpec.describe SmsRecords::GenerateMessage do
  subject(:generate_message_action) { SmsRecords::GenerateMessage.new(generate_message_params) }

  let(:generate_message_params) do
    {
      message_params: { 'store_id' => store.id },
      message_type: 'grocery_store_items_needed',
      user: user,
    }
  end
  let(:user) { User.joins(stores: :items).merge(Item.needed).first! }
  let(:store) { user.stores.joins(:items).merge(Item.needed).first! }

  describe '#grocery_store_items_needed_message_body' do
    subject(:grocery_store_items_needed_message_body) do
      generate_message_action.send(:grocery_store_items_needed_message_body)
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
