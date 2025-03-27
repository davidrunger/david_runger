RSpec.describe Request do
  it { is_expected.not_to validate_presence_of(:format) }
  it { is_expected.not_to validate_presence_of(:db) }
  it { is_expected.not_to validate_presence_of(:view) }

  it { is_expected.to belong_to(:auth_token).optional }
  it { is_expected.to belong_to(:user).optional }

  context 'when the ISP contains an ampersand' do
    subject(:request) { create(:request, isp: isp_with_ampersand) }

    let(:isp_with_ampersand) { 'AT&T' }

    it 'does not HTML-escape the ampersand' do
      expect(request.isp).to eq(isp_with_ampersand)
    end
  end
end
