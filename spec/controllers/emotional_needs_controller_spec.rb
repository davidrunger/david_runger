RSpec.describe EmotionalNeedsController do
  before { sign_in(user) }

  let(:emotional_need) { EmotionalNeed.first! }
  let(:user) { emotional_need.marriage.partners.first! }

  describe '#edit' do
    subject(:get_edit) { get(:edit, params: { id: emotional_need.id }) }

    it 'renders a form to edit the emotional need' do
      get_edit

      expect(response.body).to have_button('Update Emotional need')
    end
  end

  describe '#update' do
    subject(:patch_update) do
      patch(
        :update,
        params: {
          id: emotional_need.id,
          emotional_need: {
            name: new_emotional_need_name,
            description: new_emotional_need_description,
          },
        },
      )
    end

    let(:new_emotional_need_name) { Faker::Emotion.unique.noun.capitalize }
    let(:new_emotional_need_description) { Faker::Company.unique.bs.capitalize }

    it 'updates the specified emotional need' do
      expect {
        patch_update
      }.to change {
        emotional_need.reload.attributes.values_at(*%w[name description])
      }.to([new_emotional_need_name, new_emotional_need_description])
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) { delete(:destroy, params: { id: emotional_need.id }) }

    it 'destroys the specified emotional need' do
      expect { delete_destroy }.
        to change { user.marriage.emotional_needs.where(id: emotional_need).size }.
        by(-1)
    end
  end

  describe '#history' do
    subject(:get_history) { get(:history, params: { id: emotional_need.id }) }

    it 'renders a heading and a chartkick graph' do
      get_history

      expect(response.body).to have_css('h1', text: emotional_need.name)
      expect(response.body).to have_text('new Chartkick["LineChart"]')
    end

    context 'when `rated_user` param is "partner"' do
      subject(:get_history) do
        get(:history, params: { id: emotional_need.id, rated_user: 'partner' })
      end

      it 'renders a heading and a chartkick graph' do
        get_history

        expect(response.body).to have_css('h1', text: emotional_need.name)
        expect(response.body).to have_text('new Chartkick["LineChart"]')
      end
    end
  end
end
