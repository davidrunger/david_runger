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
    end
  end
end
