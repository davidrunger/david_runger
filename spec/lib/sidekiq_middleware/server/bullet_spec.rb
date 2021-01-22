# frozen_string_literal: true

RSpec.describe SidekiqMiddleware::Server::Bullet do
  subject(:middleware_instance) { SidekiqMiddleware::Server::Bullet.new }

  describe '#call' do
    it 'calls the provided block' do
      expect do |block|
        middleware_instance.call(:_worker, :_job, :_queue, &block)
      end.to yield_with_no_args
    end
  end
end
