RSpec.describe(Api::SectionConfigurationsController) do
  let(:user) { users(:user) }
  let(:store) { stores(:store) }

  before { sign_in(user) }

  describe '#create' do
    subject(:post_create) do
      post(:create, params: { store_id: store.id, section_configuration: attributes })
    end

    before { store_section_configurations(:store_section_configuration).destroy! }

    context 'when sections are enabled' do
      let(:attributes) do
        {
          sectioning_enabled: true,
          store_section_scheme_id: store_section_schemes(:grocery_layout).id,
        }
      end

      it 'creates the configuration' do
        expect { post_create }.to change { user.store_section_configurations.count }.by(1)
      end
    end

    context 'when sections are disabled' do
      let(:attributes) do
        { sectioning_enabled: false, store_section_scheme_id: nil }
      end

      it 'creates an opt-out configuration' do
        post_create

        expect(user.store_section_configurations.find_by!(store:)).not_to be_sectioning_enabled
      end
    end
  end

  describe '#update' do
    subject(:patch_update) do
      patch(:update, params: { store_id: store.id, section_configuration: attributes })
    end

    let(:configuration) { store_section_configurations(:store_section_configuration) }

    before { configuration }

    context 'when changing to another scheme' do
      let(:new_scheme) { create(:store_section_scheme, user:) }
      let(:attributes) do
        { sectioning_enabled: true, store_section_scheme_id: new_scheme.id }
      end

      it 'clears assignments made with the previous scheme' do
        expect { patch_update }.to change {
          configuration.item_section_assignments.count
        }.from(1).to(0)
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
