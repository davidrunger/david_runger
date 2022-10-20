# frozen_string_literal: true

RSpec.describe(GroceriesController) do
  before { sign_in(user) }

  describe '#index' do
    subject(:get_index) { get(:index) }

    context 'when the user does not have a spouse' do
      before { expect(user.spouse).to eq(nil) }

      let(:user) { users(:single_user) }

      it 'bootstraps an empty array for :spouse_stores' do
        get_index
        expect(assigns[:bootstrap_data].as_json['spouse_stores']).to eq([])
      end
    end
  end
end
