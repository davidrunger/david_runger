# frozen_string_literal: true

RSpec.describe CheckHomeLinks::Checker do
  subject(:worker) { CheckHomeLinks::Checker.new }

  let(:url) { 'https://github.com/davidrunger' }

  describe '#perform' do
    subject(:perform) { worker.perform(url) }

    let(:status) { 200 }
    let(:redis_failure_key) { worker.send(:redis_failure_key, url) }

    before do
      stub_request(:get, 'https://github.com/davidrunger').
        to_return(status:, body: '', headers: {})
    end

    context 'when a previous failure is marked in Redis' do
      before { $redis_pool.with { _1.call('set', redis_failure_key, '1') } }

      context 'when the link returns the expected status' do
        it 'does not send an email', queue_adapter: :test do
          expect { perform }.not_to enqueue_mail
        end
      end

      context 'when the link returns an unexpected status' do
        let(:status) { 404 }

        it 'sends an AdminMailer#bad_home_link email', queue_adapter: :test do
          expect { perform }.
            to enqueue_mail(AdminMailer, :bad_home_link).
            with(url, status, [200])
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
            with(url, nil, [200])
        end
      end
    end

    context 'when a previous failure did not occur within the past 48 hours' do
      before { expect($redis_pool.with { _1.call('get', redis_failure_key) }).to eq(nil) }

      context 'when the link returns an unexpected status' do
        let(:status) { 404 }

        it 'does not send an AdminMailer#bad_home_link email', queue_adapter: :test do
          expect { perform }.not_to enqueue_mail(AdminMailer, :bad_home_link)
        end

        it 'marks the failure in Redis' do
          expect { perform }.to change {
            $redis_pool.with { _1.call('get', redis_failure_key) }
          }.from(nil).to('1')
        end
      end
    end
  end
end
