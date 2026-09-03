RSpec.describe(Api::StoreSectionsController) do
  let(:user) { users(:user) }
  let(:store_section_scheme) { store_section_schemes(:grocery_layout) }

  before { sign_in(user) }

  describe '#create' do
    subject(:post_create) do
      post(
        :create,
        params: { store_section_scheme_id: store_section_scheme.id, store_section: { name: } },
      )
    end

    context 'with a valid name' do
      let(:name) { 'Frozen' }

      it 'creates a section' do
        expect { post_create }.to change { store_section_scheme.store_sections.count }.by(1)
      end
    end

    context 'with an invalid name' do
      let(:name) { '' }

      it 'returns validation errors' do
        post_create

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe '#update' do
    subject(:patch_update) do
      patch(
        :update,
        params: {
          store_section_scheme_id: store_section_scheme.id,
          id: store_section.id,
          store_section: { name: 'Fresh produce' },
        },
      )
    end

    let(:store_section) { store_sections(:produce_section) }

    it 'updates the section' do
      expect { patch_update }.to change { store_section.reload.name }.to('Fresh produce')
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) do
      delete(
        :destroy,
        params: { store_section_scheme_id: store_section_scheme.id, id: store_section.id },
      )
    end

    let(:store_section) { store_sections(:produce_section) }

    it 'destroys its assignments and the section' do
      expect { delete_destroy }.
        to change { ItemSectionAssignment.count }.by(-1).
        and change { StoreSection.count }.by(-1)
    end
  end
end
