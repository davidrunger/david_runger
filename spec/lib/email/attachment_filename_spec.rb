RSpec.describe Email::AttachmentFilename do
  describe '.sanitize' do
    subject(:sanitized_filename) { described_class.sanitize(filename) }

    context 'when the filename contains Unix path traversal' do
      let(:filename) { '../../../../app/views/mailers/admin_mailer/user_created.html.haml' }

      it { is_expected.to eq('user_created.html.haml') }
    end

    context 'when the filename contains Windows path traversal' do
      let(:filename) { '..\\..\\secrets.txt' }

      it { is_expected.to eq('secrets.txt') }
    end

    context 'when the filename contains unsafe header characters' do
      let(:filename) { " report\r\n:name?.txt\0 " }

      it { is_expected.to eq('report---name-.txt') }
    end

    context 'when the filename does not identify a file' do
      let(:filename) { '..' }

      it { is_expected.to eq('attachment') }
    end
  end
end
