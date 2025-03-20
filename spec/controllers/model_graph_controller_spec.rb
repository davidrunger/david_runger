RSpec.describe ModelGraphController do
  describe '#index' do
    subject(:get_index) { get(:index) }

    it 'bootstraps model data and responds with 200' do
      get_index

      model_metadata = controller.send(:bootstrap)[:model_metadata]
      expect(model_metadata).to be_a(Array)
      expect(model_metadata).to be_present
      expect(response).to have_http_status(200)
    end
  end
end
