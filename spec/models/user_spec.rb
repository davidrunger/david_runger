# frozen_string_literal: true

RSpec.describe User do
  subject(:user) { users(:user) }

  it { is_expected.to have_many(:sms_records) }
  it { is_expected.to have_many(:items) }
  it { is_expected.to have_many(:logs) }
  it { is_expected.to have_many(:log_shares) }

  describe 'phone validations' do
    before { user.phone = phone }

    let(:phone) { '11231231234' }

    context 'when the phone number is 11 digits long, starts with 1, and contains only digits' do
      before { user.phone = phone }

      it 'is valid' do
        expect(user).to be_valid
      end
    end

    context 'when the phone number is only 10 digits long' do
      before { expect(phone.size).to eq(10) }

      let(:phone) { super().last(10) }

      it 'is not valid' do
        expect(user).not_to be_valid
      end
    end

    context 'when the phone number does not start with 1' do
      before { expect(phone.first).not_to eq('1') }

      # rubocop:disable Performance/ArraySemiInfiniteRangeSlice
      let(:phone) { "2#{super()[1..]}" }
      # rubocop:enable Performance/ArraySemiInfiniteRangeSlice

      it 'is not valid' do
        expect(user).not_to be_valid
      end
    end

    context 'when the phone number does not contain only digits' do
      before { expect(phone.first).not_to eq('1') }

      let(:phone) { '630-1231234' }

      it 'is not valid' do
        expect(user).not_to be_valid
      end
    end
  end

  describe '#items' do
    subject(:items) { user.items }

    it 'returns a relation that allows a specific item to be found by `id`' do
      item_id = user.items.first!.id
      expect(user.items.find(item_id)).to eq(Item.find(item_id))
    end
  end

  describe '#sms_usage' do
    subject(:sms_usage) { user.sms_usage }

    let(:sms_cost_1) { 0.006 }
    let(:sms_cost_2) { 0.008 }

    before do
      user.sms_records.destroy_all
      create(:sms_record, user: user, cost: sms_cost_1)
      create(:sms_record, user: user, cost: sms_cost_2)
    end

    it "returns the total cost of the user's sms_records" do
      expect(sms_usage).to eq(sms_cost_1 + sms_cost_2)
    end
  end
end
