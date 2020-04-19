# frozen_string_literal: true

require 'spec_helper'

RSpec.describe User do
  subject(:user) { users(:user) }

  it { is_expected.to have_many(:sms_records) }
  it { is_expected.to have_many(:items) }
  it { is_expected.to have_many(:logs) }
  it { is_expected.to have_many(:log_shares) }

  describe '#items' do
    subject(:items) { user.items }

    it 'returns a relation that allows a specific item to be found by `id`' do
      item_id = user.items.first!.id
      expect(user.items.find(item_id)).to eq(Item.find(item_id))
    end
  end

  describe '#may_send_sms?' do
    subject(:may_send_sms?) { user.may_send_sms? }

    context 'when user has already used up his SMS allowance' do
      before do
        user.sms_records.destroy_all
        create(:sms_record, user: user, cost: 0.006)
        user.update!(sms_allowance: 0.006)
      end

      it 'returns false' do
        expect(may_send_sms?).to eq(false)
      end
    end

    context 'when user has part of his SMS allowance still remaining' do
      before do
        user.sms_records.destroy_all
        create(:sms_record, user: user, cost: 0.006)
        user.update!(sms_allowance: 0.007)
      end

      it 'returns true' do
        expect(may_send_sms?).to eq(true)
      end
    end
  end

  describe 'sms_usage' do
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
