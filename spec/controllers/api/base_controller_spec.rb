RSpec.describe Api::BaseController, :without_verifying_authorization do
  controller do
    skip_before_action :authenticate_user!

    def index
      render_schema_json({ some_really: 'amazing data' }, schema: params[:schema])
    end
  end

  describe '#render_schema_json' do
    subject(:get_index) { get(:index, params: { schema: }) }

    context 'when there is no JSON schema for the action' do
      let(:schema) { 'no/such/schema' }

      it 'raises a JSON::Schema::ReadFailed error' do
        expect { get(:index) }.to raise_error(JSON::Schema::ReadFailed)
      end
    end

    context 'when the rendered data does not conform to the JSON schema' do
      let(:schema) { 'items/destroy' }

      it 'raises an Api::BaseController::SchemaValidationError' do
        expect { get_index }.to raise_error(Api::BaseController::SchemaValidationError)
      end
    end
  end
end
