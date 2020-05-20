# frozen_string_literal: true

RSpec.describe IpBlock, type: :model do
  it { is_expected.to validate_presence_of(:ip) }
end
