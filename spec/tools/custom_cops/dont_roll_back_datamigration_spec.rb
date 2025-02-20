require 'rubocop'
require 'rubocop/rspec/support'
require Rails.root.join('tools/custom_cops/dont_roll_back_datamigration.rb')

RSpec.describe CustomCops::DontRollBackDatamigration, :config do
  include RuboCop::RSpec::ExpectOffense

  context 'when calling within_transaction with a rollback keyword argument' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        within_transaction(rollback: true) do
                           ^^^^^^^^^^^^^^ Only use the `:rollback` keyword argument for testing. Remove before pushing.
          perform_task
        end
      RUBY
    end
  end

  context 'when calling within_transaction with a positional argument' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        within_transaction(:rollback) do
          perform_task
        end
      RUBY
    end
  end

  context 'when calling within_transaction without any argument' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        within_transaction do
          perform_task
        end
      RUBY
    end
  end

  context 'when calling a different method with a rollback keyword argument' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        some_other_method(rollback: true) do
          perform_task
        end
      RUBY
    end
  end

  context 'when calling within_transaction with other keyword arguments' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        within_transaction(foo: true, bar: false) do
          perform_task
        end
      RUBY
    end
  end
end
