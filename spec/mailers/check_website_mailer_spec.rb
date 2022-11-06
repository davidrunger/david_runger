# frozen_string_literal: true

RSpec.describe CheckWebsiteMailer do
  before do
    User.find_or_initialize_by(id: 1).update!(email: user_1_email)
    User.find_or_initialize_by(id: 30).update!(email: user_30_email)
  end

  let(:user_1_email) { Faker::Internet.email }
  let(:user_30_email) { Faker::Internet.email }

  describe '#item_available' do
    subject(:mail) { CheckWebsiteMailer.item_available(true, false, 2) }

    it 'is sent to Users 30 and 1' do
      expect(mail.to).to match_array([user_30_email, user_1_email])
    end

    it 'has a subject that says the item is available' do
      expect(mail.subject).to eq(
        'The item you are waiting for is available',
      )
    end

    describe 'the email body' do
      subject(:body) { mail.body.to_s }

      it 'has details about the item availability' do
        expect(body).to have_text('Available in store: true')
        expect(body).to have_text('Available for pickup: false')
        expect(body).to have_text('Quantity: 2')
      end
    end
  end

  describe '#restock_planned' do
    subject(:mail) { CheckWebsiteMailer.restock_planned([{ 'date' => '2022-12-25' }]) }

    it 'is sent to Users 30 and 1' do
      expect(mail.to).to match_array([user_30_email, user_1_email])
    end

    it 'has a subject that says the item is available' do
      expect(mail.subject).to eq(
        'A restock is planned for the item you are waiting for',
      )
    end

    describe 'the email body' do
      subject(:body) { mail.body.to_s }

      it 'has details about the planned restock' do
        expect(body).to have_text('Restocks: [{"date"=>"2022-12-25"}]')
      end
    end
  end
end
