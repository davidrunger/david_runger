RSpec.describe CheckInsController do
  before { sign_in(user) }

  let(:check_in) { CheckIn.first! }
  let(:user) { check_in.marriage.partners.first! }

  describe '#index' do
    subject(:get_index) { get(:index) }

    context 'when the current user does not yet have a marriage' do
      before { user.marriage&.destroy! }

      it 'creates a marriage for the user' do
        expect { get_index }.to change { user.reload.marriage }.from(nil).to(Marriage)
      end
    end

    context 'when the current user already has a marriage' do
      before { expect(user.marriage).to be_present }

      it 'does not change the marriage of the user' do
        expect { get_index }.not_to change { user.reload.marriage.id }
      end
    end
  end

  describe '#show' do
    subject(:get_show) { get(:show, params: { id: check_in.id }) }

    it 'renders the check-in' do
      get_show

      expect(response.body).to have_text(/Marriage Check-In #\d+/)
    end

    describe 'bootstrap data' do
      subject(:bootstrap_data) do
        get_show
        assigns[:bootstrap_data].as_json
      end

      it 'sets the correct bootstrap data for the check-in' do
        expect(bootstrap_data['check_in'].keys).to eq(%w[id submitted])
      end
    end
  end
end
