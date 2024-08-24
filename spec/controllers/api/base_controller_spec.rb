RSpec.describe Api::BaseController, :without_verifying_authorization do
  controller do
    skip_before_action :authenticate_user!

    def index
      render_schema_json({ some_really: 'amazing data' })
    end
  end

  describe '#render_schema_json' do
    subject(:get_index) { get(:index) }

    context 'when there is no JSON schema for the action' do
      it 'raises a JSON::Schema::ReadFailed error' do
        expect { get(:index) }.to raise_error(JSON::Schema::ReadFailed)
      end
    end

    context 'when there is a JSON schema for the action' do
      before do
        allow(Rails.root).to receive(:join).and_wrap_original do |original_method, *args|
          if args == ['spec/support/schemas/base/index.json']
            Rails.root.join('spec/support/schemas/items/create.json')
          else
            original_method.call(*args)
          end
        end
      end

      context 'when the rendered data does not conform to the JSON schema' do
        it 'raises an Api::BaseController::SchemaValidationError' do
          expect { get_index }.to raise_error(Api::BaseController::SchemaValidationError)
        end
      end
    end
  end
end
