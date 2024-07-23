module SidekiqSpecHelpers
  # NOTE: This is a workaround for the issue mentioned here
  # https://github.com/sidekiq/sidekiq/issues/ 6069#issuecomment-1755344641 .
  def with_inline_sidekiq
    original_test_mode = Sidekiq::Testing.__test_mode
    Sidekiq::Testing.inline!

    yield

    Sidekiq::Testing.__set_test_mode(original_test_mode)
  end
end
