# frozen_string_literal: true

RSpec.describe UserDecorator do
  subject(:decorated_user) { user.decorate }

  let(:user) { users(:user) }

  describe '#partially_anonymized_username' do
    subject(:partially_anonymized_username) { decorated_user.partially_anonymized_username }

    context "when the user's email is short" do
      before { user.update!(email: 'a@b.c') }

      it "returns a string based on the user's id" do
        expect(partially_anonymized_username).to eq("User #{user.id}")
      end
    end

    context "when the user's email is not particularly short" do
      let(:email) { '0123456789@b.c' }

      before { user.update!(email: email) }

      it "returns a partially anonymized string based on the user's email" do
        expect(partially_anonymized_username).not_to include(email)
        expect(partially_anonymized_username).not_to include(email.split('@').first.presence!)
        expect(partially_anonymized_username).to eq(email.sub('3456', '...'))
      end
    end
  end
end
