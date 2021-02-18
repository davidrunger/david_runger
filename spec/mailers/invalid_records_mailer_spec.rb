# frozen_string_literal: true

RSpec.describe InvalidRecordsMailer do
  describe '#invalid_records' do
    subject(:mail) { InvalidRecordsMailer.invalid_records(klass_name, number_of_invalid_records) }

    let(:klass_name) { 'User' }
    let(:number_of_invalid_records) { 1 }

    it 'is sent from reply@davidrunger.com' do
      expect(mail.from).to eq(['reply@davidrunger.com'])
    end

    it 'is sent to davidjrunger@gmail.com' do
      expect(mail.to).to eq(['davidjrunger@gmail.com'])
    end

    it 'has a subject mentioning that there is at least one invalid record' do
      expect(mail.subject).to eq(
        "There are #{number_of_invalid_records} invalid #{klass_name}s. :(",
      )
    end

    describe 'the email body' do
      subject(:body) { mail.body.to_s }

      it 'mentions the class name and number of invalid records' do
        expect(body).to have_text(klass_name)
        expect(body).to have_text(number_of_invalid_records)
      end
    end
  end
end
