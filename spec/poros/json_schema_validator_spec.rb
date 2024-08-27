RSpec.describe JsonSchemaValidator do
  subject(:json_schema_validator) { JsonSchemaValidator.new(data, controller_action:) }

  let(:data) { { cool: 'data' } }
  let(:controller_action) { 'api/logs/create' }

  describe '#api?' do
    subject(:api?) { json_schema_validator.send(:api?) }

    context 'when the controller action is an API action' do
      let(:controller_action) { 'api/logs/create' }

      it 'returns true' do
        expect(api?).to eq(true)
      end
    end
  end
end
