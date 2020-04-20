# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Log do
  subject(:log) { logs(:number_log) }

  it { is_expected.to have_many(:log_shares) }
end
