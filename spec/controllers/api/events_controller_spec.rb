RSpec.describe Api::EventsController do
  describe '#create' do
    subject(:post_create) { post(:create, params:) }

    let(:data) { { page_url: DavidRunger::CANONICAL_URL } }
    let(:params) { { data:, type: } }
    let(:type) { 'scroll' }
    let(:user_agent) { 'Public telemetry controller spec' }

    before { request.headers['User-Agent'] = user_agent }

    context 'when the event is valid' do
      it 'returns 201 and creates the event' do
        expect { post_create }.to change { Event.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(Event.last!).to have_attributes(
          data: data.stringify_keys,
          type:,
          user_agent:,
        )
      end

      it 'enqueues IP enrichment for the event' do
        post_create

        event = Event.last!
        expect(FetchIpInfoForRecord).
          to have_enqueued_sidekiq_job.
          with(Event.name, event.id)
      end
    end

    context 'when the event is invalid' do
      let(:type) { 'a' * (Event::MAX_TYPE_LENGTH + 1) }

      it 'returns 422 without creating an event or enqueuing IP enrichment' do
        expect { post_create }.
          not_to change { [Event.count, Sidekiq::Queues['default'].size] }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
