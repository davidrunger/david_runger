module SidekiqSpecHelpers
  # NOTE: This is a workaround for the issue mentioned here
  # https://github.com/sidekiq/sidekiq/issues/ 6069#issuecomment-1755344641 .
  def with_inline_sidekiq(&block)
    original_test_mode = Sidekiq::Testing.__test_mode
    Sidekiq::Testing.inline!

    # Disabling Prosopite here risks false negatives, but it avoids false
    # positives, so let's do it.
    Prosopite.pause(&block)

    Sidekiq::Testing.__set_test_mode(original_test_mode)
  end
end
