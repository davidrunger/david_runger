RSpec.describe CheckLinks::Checker do
  subject(:worker) { CheckLinks::Checker.new }

  let(:url) { 'https://github.com/davidrunger' }
  let(:page_source_url) { 'https://davidrunger.com/blog/using-vs-code' }

  describe '#perform' do
    subject(:perform) { worker.perform(url, page_source_url) }

    let(:status) { 200 }
    let(:redis_failure_key) { worker.send(:redis_failure_key, url) }

    before do
      stub_request(:get, url).
        to_return(status:, body: '', headers: {})
    end

    context 'when a previous failure is marked in Redis' do
      before { $redis_pool.with { _1.call('set', redis_failure_key, '1') } }

      context 'when the URL is expected to return 200' do
        let(:url) { 'https://gem.wtf/' }

        context 'when the URL returns 200' do
          let(:status) { 200 }

          it 'does not send an email', queue_adapter: :test do
            expect { perform }.not_to enqueue_mail
          end
        end
      end

      context 'when the URL is expected to return 302' do
        let(:url) { 'https://gem.wtf/bake' }

        context 'when the URL returns 302' do
          let(:status) { 302 }

          it 'does not send an email', queue_adapter: :test do
            expect { perform }.not_to enqueue_mail
          end
        end
      end

      context 'when the link returns an unexpected status' do
        let(:status) { 404 }

        it 'sends an AdminMailer#broken_link email', queue_adapter: :test do
          expect { perform }.
            to enqueue_mail(AdminMailer, :broken_link).
            with(url, page_source_url, status, [200])
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

        it 'reports via Rails.error at info level' do
          expect(Rails.error).
            to receive(:report).
            with(
              Faraday::ConnectionFailed,
              severity: :info,
              handled: true,
              context: { url: },
              source: 'application',
            ).
            and_call_original

          perform
        end

        it 'sends an AdminMailer#broken_link email', queue_adapter: :test do
          expect { perform }.
            to enqueue_mail(AdminMailer, :broken_link).
            with(url, page_source_url, nil, [200])
        end
      end
    end

    context 'when a previous failure did not occur within the past 48 hours' do
      before { expect($redis_pool.with { _1.call('get', redis_failure_key) }).to eq(nil) }

      context 'when the link returns an unexpected status' do
        let(:status) { 404 }

        it 'does not send an AdminMailer#broken_link email', queue_adapter: :test do
          expect { perform }.not_to enqueue_mail(AdminMailer, :broken_link)
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
