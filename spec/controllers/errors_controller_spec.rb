RSpec.describe ErrorsController do
  describe '#not_found' do
    subject(:get_not_found) { get(:not_found) }

    it %(says "The page you were looking for doesn't exist.") do
      get_not_found
      expect(response.body).to have_text("The page you were looking for doesn't exist.")
    end
  end

  describe '#unacceptable' do
    subject(:get_unacceptable) { get(:unacceptable) }

    it 'says "The change you wanted was rejected."' do
      get_unacceptable
      expect(response.body).to have_text('The change you wanted was rejected.')
    end
  end

  describe '#internal_error' do
    subject(:get_internal_error) { get(:internal_error) }

    it 'says "Sorry, something went wrong."' do
      get_internal_error
      expect(response.body).to have_text('Sorry, something went wrong.')
    end

    context 'when `rollbar.exception_uuid` has been set in `request.env`' do
      before { request.env['rollbar.exception_uuid'] = rollbar_uuid }

      let(:rollbar_uuid) { SecureRandom.uuid }

      it 'mentions the Rollbar UUID' do
        get_internal_error
        expect(response.body).to have_text("Please provide this error ID: #{rollbar_uuid}")
      end
    end
  end

  context 'when the request format is json', request_format: :json do
    describe '#not_found' do
      subject(:get_not_found) { get(:not_found) }

      it %(says "The page you were looking for doesn't exist.") do
        get_not_found
        expect(json_response).to eq({ 'error' => 'Not Found' })
      end
    end

    describe '#unacceptable' do
      subject(:get_unacceptable) { get(:unacceptable) }

      it 'says "The change you wanted was rejected."' do
        get_unacceptable
        expect(json_response).to eq({ 'error' => 'Params unacceptable' })
      end
    end

    describe '#internal_error' do
      subject(:get_internal_error) { get(:internal_error) }

      it 'says "Sorry, something went wrong."' do
        get_internal_error
        expect(json_response).to eq({ 'error' => 'Internal server error' })
      end
    end
  end
end
