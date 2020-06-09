# frozen_string_literal: true

RSpec.describe Request do
  it { is_expected.not_to validate_presence_of(:format) }
  it { is_expected.not_to validate_presence_of(:db) }
  it { is_expected.not_to validate_presence_of(:view) }
end
