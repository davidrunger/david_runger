# frozen_string_literal: true

RSpec.describe CheckHomeLinks::Checker do
  subject(:worker) { CheckHomeLinks::Checker.new }

  let(:url) { 'https://github.com/davidrunger' }

  describe '#perform' do
    subject(:perform) { worker.perform(url) }

    let(:status) { 200 }

    before do
      stub_request(:get, 'https://github.com/davidrunger').
        to_return(status:, body: '', headers: {})
    end

    context 'when the link returns the expected status' do
      it 'does not send an email', queue_adapter: :test do
        expect { perform }.not_to enqueue_mail
        # expect { perform }.not_to enqueue_mail(AdminMailer, :bad_home_link)
      end
    end

    context 'when the link returns an unexpected status' do
      let(:status) { 404 }

      it 'sends an AdminMailer#bad_home_link email', queue_adapter: :test do
        expect { perform }.
          to enqueue_mail(AdminMailer, :bad_home_link).
          with(url, status, 200)
      end
    end

    context 'when fetching the URL raises an error' do
      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(Faraday::Connection).
          to receive(:get).
          and_raise(Faraday::ConnectionFailed, 'Operation timed out - user specified timeout')
        # rubocop:enable RSpec/AnyInstance
      end

      it 'sends an AdminMailer#bad_home_link email', queue_adapter: :test do
        expect { perform }.
          to enqueue_mail(AdminMailer, :bad_home_link).
          with(url, nil, 200)
      end
    end
  end
end
