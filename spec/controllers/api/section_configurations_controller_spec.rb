RSpec.describe(Api::SectionConfigurationsController) do
  subject(:patch_update) do
    patch(:update, params: { store_id: store.id, section_configuration: attributes })
  end

  let(:user) { users(:user) }
  let(:store) { stores(:store) }

  before { sign_in(user) }

  describe '#update' do
    context 'when the store has no configuration' do
      before { store_section_configurations(:store_section_configuration).destroy! }

      context 'when choosing a scheme' do
        let(:store_section_scheme) { store_section_schemes(:grocery_layout) }
        let(:attributes) do
          { sectioning_enabled: true, store_section_scheme_id: store_section_scheme.id }
        end

        it 'creates the configuration' do
          expect { patch_update }.to change { user.store_section_configurations.count }.by(1)

          configuration = user.store_section_configurations.find_by!(store:)
          expect(configuration).to be_sectioning_enabled
          expect(configuration.store_section_scheme).to eq(store_section_scheme)
        end
      end

      context 'when choosing not to use sections' do
        let(:attributes) { { sectioning_enabled: false, store_section_scheme_id: nil } }

        it 'creates an opt-out configuration' do
          expect { patch_update }.to change { user.store_section_configurations.count }.by(1)

          configuration = user.store_section_configurations.find_by!(store:)
          expect(configuration).not_to be_sectioning_enabled
          expect(configuration.store_section_scheme).to be_nil
        end
      end
    end

    context 'when changing to another scheme' do
      let(:configuration) { store_section_configurations(:store_section_configuration) }
      let(:new_scheme) { create(:store_section_scheme, user:) }
      let(:attributes) do
        { sectioning_enabled: true, store_section_scheme_id: new_scheme.id }
      end

      before { configuration }

      it 'clears assignments made with the previous scheme' do
        expect { patch_update }.to change {
          configuration.item_section_assignments.count
        }.from(1).to(0)
      end
    end

    context 'when temporarily disabling sections' do
      let(:configuration) { store_section_configurations(:store_section_configuration) }
      let(:attributes) do
        {
          sectioning_enabled: false,
          store_section_scheme_id: configuration.store_section_scheme_id,
        }
      end

      it 'retains the scheme and its assignments' do
        expect { patch_update }.not_to change { configuration.item_section_assignments.count }

        expect(configuration.reload).not_to be_sectioning_enabled
        expect(configuration.store_section_scheme).to eq(store_section_schemes(:grocery_layout))
      end
    end

    context 'when the scheme does not belong to the user' do
      let(:attributes) do
        {
          sectioning_enabled: true,
          store_section_scheme_id: create(:store_section_scheme).id,
        }
      end

      it 'returns validation errors' do
        patch_update

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
