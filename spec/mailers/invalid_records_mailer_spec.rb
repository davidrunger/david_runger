# frozen_string_literal: true

RSpec.describe InvalidRecordsMailer do
  describe '#invalid_records' do
    subject(:mail) { InvalidRecordsMailer.invalid_records(invalid_records_count_hash) }

    let(:invalid_records_count_hash) { { 'Item' => 0, 'Log' => 2, 'User' => 1, 'Workout' => 0 } }

    it 'is sent from reply@davidrunger.com' do
      expect(mail.from).to eq(['reply@davidrunger.com'])
    end

    it 'is sent to davidjrunger@gmail.com' do
      expect(mail.to).to eq(['davidjrunger@gmail.com'])
    end

    it 'has a subject mentioning that there is at least one invalid record' do
      expect(mail.subject).to eq('There is at least one invalid record. :(')
    end

    describe 'the email body' do
      subject(:body) { mail.body.to_s }

      it 'lists in the body only the classes that have at least one invalid record' do
        klass_names_with_no_invalid_records, klass_names_with_invalid_records =
          invalid_records_count_hash.
            partition { |_key, value| value == 0 }.
            map { |partition| partition.map(&:first).map(&:presence!) }

        expect(body).to include(CGI.escapeHTML(JSON.pretty_generate('Log' => 2, 'User' => 1)))

        klass_names_with_no_invalid_records.each do |klass_name|
          expect(body).not_to include(klass_name)
        end

        klass_names_with_invalid_records.each do |klass_name|
          expect(body).to include(klass_name)
        end
      end
    end
  end
end
