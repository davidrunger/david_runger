# frozen_string_literal: true

RSpec.describe DataMonitorMailer do
  describe '#expectation_not_met' do
    subject(:mail) do
      DataMonitorMailer.expectation_not_met(
        check_name,
        actual_value,
        expected_range_string,
        check_run_at,
      )
    end

    let(:check_name) { 'DataMonitors::SomeModel#some_queried_value' }
    let(:actual_value) { 10 }
    let(:expected_range_string) { '5..20' }
    let(:check_run_at) { Time.current.to_s }

    it 'is sent from reply@davidrunger.com' do
      expect(mail.from).to eq(['reply@davidrunger.com'])
    end

    it 'is sent to davidjrunger@gmail.com' do
      expect(mail.to).to eq(['davidjrunger@gmail.com'])
    end

    it 'has a subject mentioning that the check failed to its expectation' do
      expect(mail.subject).to eq("#{check_name} failed to meet its expectation 😰")
    end

    describe 'the email body' do
      subject(:body) { mail.body.to_s }

      it 'mentions the check name' do
        expect(body).to have_text(check_name)
      end

      it 'states the actual value' do
        expect(body).to have_text("Actual value: #{actual_value}")
      end

      it 'states the expected value' do
        expect(body).to have_text("Expected value: #{expected_range_string}")
      end

      it 'states the time at which the check was performed', :frozen_time do
        expect(body).to have_text("Checked at: #{Time.current}")
      end
    end
  end
end
