# frozen_string_literal: true

RSpec.describe(AdminUser) do
  subject(:admin_user) { AdminUser.first! }

  describe '#display_name' do
    subject(:display_name) { admin_user.display_name }

    before { admin_user.update!(email: "#{email_first_part}@gmail.com") }

    let(:email_first_part) { 'davidjrunger' }

    it 'returns the part of their email preceding the @' do
      expect(display_name).to eq(email_first_part)
    end
  end
end
