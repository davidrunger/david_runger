# frozen_string_literal: true

RSpec.describe AuthToken do
  subject(:auth_token) { AuthToken.first! }

  it { is_expected.to validate_uniqueness_of(:secret).scoped_to(:user_id) }

  it { is_expected.to belong_to(:user) }
end
