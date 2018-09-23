require 'spec_helper'

RSpec.describe Request do
  describe '::recent' do
    context 'called without an argument' do
      subject { Request.recent }

      let!(:recent_request) { create(:request, requested_at: 23.hours.ago) }
      let!(:old_request) { create(:request, requested_at: 25.hours.ago) }

      it 'includes only recent requests within the last day' do
        expect(subject).to include(recent_request)
        expect(subject).not_to include(old_request)
      end
    end

    context 'called with an argument' do
      subject { Request.recent(2.days) }

      let!(:recent_request) { create(:request, requested_at: 47.hours.ago) }
      let!(:old_request) { create(:request, requested_at: 49.hours.ago) }

      it 'includes requests within the specified time period' do
        expect(subject).to include(recent_request)
        expect(subject).not_to include(old_request)
      end
    end
  end
end
