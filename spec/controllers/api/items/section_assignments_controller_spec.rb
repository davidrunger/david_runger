RSpec.describe(Api::Items::SectionAssignmentsController) do
  let(:user) { users(:user) }
  let(:store) { stores(:store) }
  let(:item) { items(:item) }
  let(:store_section_configuration) { store_section_configurations(:store_section_configuration) }

  before do
    sign_in(user)
    store_section_configuration
  end

  describe '#update' do
    subject(:patch_update) do
      patch(
        :update,
        params: {
          store_id: store.id,
          item_id: item.id,
          section_assignment: { store_section_id: store_section.id },
        },
      )
    end

    let(:store_section) do
      create(:store_section, store_section_scheme: store_section_schemes(:grocery_layout))
    end

    it 'assigns the item availability to the section' do
      expect { patch_update }.
        to change {
          item_section_assignments(:item_section_assignment).reload.store_section
        }.to(store_section)
    end

    it 'returns no content' do
      patch_update

      expect(response).to have_http_status(:no_content)
    end

    context 'when the user has chosen not to use sections at the store' do
      before do
        store_section_configuration.update!(
          sectioning_enabled: false,
          store_section_scheme: nil,
        )
      end

      it 'returns not found' do
        patch_update

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#destroy' do
    subject(:delete_destroy) do
      delete(:destroy, params: { store_id: store.id, item_id: item.id })
    end

    it 'removes the assignment' do
      expect { delete_destroy }.to change { ItemSectionAssignment.count }.by(-1)
    end
  end
end
