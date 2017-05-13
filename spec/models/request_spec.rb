require 'spec_helper'

describe Request do
  describe '::human' do
    subject { Request.human }

    let!(:human_request) { create(:request, :chrome) }
    let!(:bot_request) { create(:request, :bot) }

    it 'includes only human requests' do
      expect(subject).to include(human_request)
      expect(subject).not_to include(bot_request)
    end
  end

  describe '::recent' do
    subject { Request.recent }

    let!(:recent_request) { create(:request, requested_at: 2.hours.ago) }
    let!(:old_request) { create(:request, requested_at: 2.days.ago) }

    it 'includes only recent requests' do
      expect(subject).to include(recent_request)
      expect(subject).not_to include(old_request)
    end
  end

  describe '::ordered' do
    subject { Request.order('requests.requested_at') }

    let!(:newer_request) { create(:request, requested_at: 2.hours.ago) }
    let!(:older_request) { create(:request, requested_at: 2.days.ago) }

    it 'orders the requests by requested_at' do
      expect(subject).to eq([older_request, newer_request])
    end
  end
end
