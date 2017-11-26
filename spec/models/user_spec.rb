require 'spec_helper'

RSpec.describe User do
  it { should have_many(:sms_records) }
end
