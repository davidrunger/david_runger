# frozen_string_literal: true

RSpec.describe SmsRecord do
  subject(:sms_record) { sms_records(:sms_record) }

  it { is_expected.to belong_to(:user) }
end
