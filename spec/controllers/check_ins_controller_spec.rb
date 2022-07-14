# frozen_string_literal: true

RSpec.describe CheckInsController do
  before { sign_in(user) }

  let(:check_in) { CheckIn.first! }
  let(:user) { check_in.marriage.partner_1 }

  describe '#show' do
    subject(:get_show) { get(:show, params: { id: check_in.id }) }

    it 'renders the check-in' do
      get_show

      expect(response.body).to have_text(/Marriage Check-In #\d+/)
    end

    it 'sets the correct bootstrap data for the check-in' do
      get_show

      expect(assigns[:bootstrap_data].as_json['check_in'].keys).to eq(%i[id])
    end
  end
end
