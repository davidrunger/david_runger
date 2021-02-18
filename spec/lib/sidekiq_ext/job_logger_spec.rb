# frozen_string_literal: true

RSpec.describe SidekiqExt::JobLogger do
  subject(:logger) { SidekiqExt::JobLogger.new }

  describe '#job_hash_context' do
    subject(:job_hash_context) { logger.job_hash_context(job_hash) }

    let(:job_hash) do
      {
        'bid' => nil,
        'jid' => jid,
        'tags' => nil,
        'queue' => 'default',
        'class' => 'SomeWorkerClass',
        'args' => ['one', 2, true],
      }
    end
    let(:jid) { SecureRandom.uuid }

    it 'returns the expected job hash context' do
      expect(job_hash_context).to eq(
        jid: jid,
        queue: 'default',
        class: 'SomeWorkerClass',
        args: '["one", 2, true]',
      )
    end
  end
end
