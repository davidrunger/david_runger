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
      it 'raises an Errno::ENOENT error' do
        expect { get(:index) }.to raise_error(Errno::ENOENT)
      end
    end

    context 'when there is a JSON schema for the action' do
      before do
        allow(Rails.root).to receive(:join).and_wrap_original do |original_method, *args|
          if args == ['spec/support/schemas/api/base/index.json']
            Rails.root.join('spec/support/schemas/api/items/create.json')
          else
            original_method.call(*args)
          end
        end
      end

      context 'when the rendered data does not conform to the JSON schema' do
        it 'raises a JsonSchemaValidator::NonconformingData' do
          expect { get_index }.to raise_error(JsonSchemaValidator::NonconformingData)
        end
      end
    end
  end
end
