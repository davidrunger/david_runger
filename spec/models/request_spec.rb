# frozen_string_literal: true

RSpec.describe Request do
  describe 'validations' do
    it { is_expected.not_to validate_presence_of(:format) }
    it { is_expected.not_to validate_presence_of(:db) }
    it { is_expected.not_to validate_presence_of(:view) }
  end

  describe '::recent' do
    # rubocop:disable RSpec/MultipleExpectations
    context 'when called without an argument' do
      subject(:recent_requests) { Request.recent }

      let!(:recent_request) { create(:request, requested_at: 23.hours.ago) }
      let!(:old_request) { create(:request, requested_at: 25.hours.ago) }

      it 'includes only recent requests within the last day' do
        expect(recent_requests).to include(recent_request)
        expect(recent_requests).not_to include(old_request)
      end
    end

    context 'when called with an argument' do
      subject(:requests_in_last_2_days) { Request.recent(2.days) }

      let!(:recent_request) { create(:request, requested_at: 47.hours.ago) }
      let!(:old_request) { create(:request, requested_at: 49.hours.ago) }

      it 'includes requests within the specified time period' do
        expect(requests_in_last_2_days).to include(recent_request)
        expect(requests_in_last_2_days).not_to include(old_request)
      end
    end
    # rubocop:enable RSpec/MultipleExpectations
  end
end
