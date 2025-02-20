require 'rubocop'
require 'rubocop/rspec/support'
require Rails.root.join('tools/custom_cops/dont_include_sidekiq_worker.rb')

RSpec.describe CustomCops::DontIncludeSidekiqWorker, :config do
  include RuboCop::RSpec::ExpectOffense

  context 'when using `include Sidekiq::Worker`' do
    it 'registers an offense and can autocorrect it' do
      expect_offense(<<~RUBY)
        class MyWorker
          include Sidekiq::Worker
          ^^^^^^^^^^^^^^^^^^^^^^^ Use `prepend ApplicationWorker` rather than `include Sidekiq::Worker` or `include Sidekiq::Job`
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyWorker
          prepend ApplicationWorker
        end
      RUBY
    end
  end

  context 'when using `include Sidekiq::Job`' do
    it 'registers an offense and can autocorrect it' do
      expect_offense(<<~RUBY)
        class MyWorker
          include Sidekiq::Job
          ^^^^^^^^^^^^^^^^^^^^ Use `prepend ApplicationWorker` rather than `include Sidekiq::Worker` or `include Sidekiq::Job`
        end
      RUBY

      expect_correction(<<~RUBY)
        class MyWorker
          prepend ApplicationWorker
        end
      RUBY
    end
  end

  context 'when using `prepend ApplicationWorker`' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class MyWorker
          prepend ApplicationWorker
        end
      RUBY
    end
  end

  context 'when not including Sidekiq::Worker' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        class MyWorker
        end
      RUBY
    end
  end
end
