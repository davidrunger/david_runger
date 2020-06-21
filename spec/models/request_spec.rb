# frozen_string_literal: true

RSpec.describe Request do
  it { is_expected.not_to validate_presence_of(:format) }
  it { is_expected.not_to validate_presence_of(:db) }
  it { is_expected.not_to validate_presence_of(:view) }

  it { is_expected.to belong_to(:auth_token).optional }
  it { is_expected.to belong_to(:user).optional }
end
