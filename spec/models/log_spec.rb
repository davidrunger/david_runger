# frozen_string_literal: true

RSpec.describe Log do
  subject(:log) { logs(:number_log) }

  it { is_expected.to have_many(:log_shares) }
end
