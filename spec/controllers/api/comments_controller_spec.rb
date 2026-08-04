RSpec.describe Api::CommentsController do
  describe '#index' do
    subject(:get_index) { get(:index) }

    before do
      request.headers['Referer'] = referer
    end

    context 'when there is no referer' do
      let(:referer) { nil }

      it 'returns an empty array' do
        get_index

        expect(response.parsed_body).to eq([])
      end

      it 'does not write the read-only request session back to the client' do
        get_index

        expect(request.session_options[:skip]).to eq(true)
      end
    end
  end
end
