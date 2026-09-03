RSpec.describe(Api::StoreSectionSchemesController) do
  let(:user) { users(:user) }

  before { sign_in(user) }

  describe '#index' do
    it 'returns the current user\'s schemes' do
      get(:index)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['store_section_schemes'].pluck('id')).to include(
        store_section_schemes(:grocery_layout).id,
      )
    end
  end

  describe '#create' do
    subject(:post_create) { post(:create, params:) }

    context 'with a valid name' do
      let(:params) { { store_section_scheme: { name: 'Warehouse layout' } } }

      it 'creates a scheme' do
        expect { post_create }.to change { user.store_section_schemes.count }.by(1)
      end

      it 'returns no content' do
        post_create

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with an invalid name' do
      let(:params) { { store_section_scheme: { name: '' } } }

      it 'returns validation errors' do
        post_create

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe '#update' do
    subject(:patch_update) { patch(:update, params:) }

    let(:store_section_scheme) { store_section_schemes(:grocery_layout) }

    context 'with a valid name' do
      let(:params) do
        { id: store_section_scheme.id, store_section_scheme: { name: 'Updated layout' } }
      end

      it 'updates the scheme' do
        expect { patch_update }.to change { store_section_scheme.reload.name }.to('Updated layout')
      end

      it 'returns no content' do
        patch_update

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with an invalid name' do
      let(:params) do
        { id: store_section_scheme.id, store_section_scheme: { name: '' } }
      end

      it 'returns validation errors' do
        patch_update

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
