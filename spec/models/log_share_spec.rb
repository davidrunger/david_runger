# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LogShare do
  subject(:log_share) { log_shares(:log_share) }

  it { is_expected.to belong_to(:log) }

  it { is_expected.to validate_presence_of(:email) }
end
