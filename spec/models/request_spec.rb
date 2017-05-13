require 'spec_helper'

describe Request do
  describe '::human' do
    subject { Request.human }
    let!(:human_request) { create(:request, :chrome) }
    let!(:bot_request) { create(:request, :bot) }

    it { is_expected.to include(human_request) }
    it { is_expected.not_to include(bot_request) }
  end

  describe '::recent' do
    subject { Request.recent }
    let(:recent_request) { create(:request, requested_at: 2.hours.ago) }
    let(:old_request) { create(:request, requested_at: 2.days.ago) }

    it { is_expected.to include(recent_request) }
    it { is_expected.not_to include(old_request) }
  end
end
