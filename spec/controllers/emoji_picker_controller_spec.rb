RSpec.describe(EmojiPickerController) do
  describe '#index' do
    subject(:get_index) { get(:index) }

    it 'responds with 200' do
      get_index
      expect(response).to have_http_status(200)
    end

    it 'has a title including "Emoji Picker"' do
      get_index
      expect(response.body).to have_title(/\AEmoji Picker - David Runger\z/)
    end
  end
end
