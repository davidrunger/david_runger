module SidekiqSpecHelpers
  # NOTE: This is a workaround for the issue mentioned here
  # https://github.com/sidekiq/sidekiq/issues/6069#issuecomment-1755344641 .
  def self.with_global_inline_sidekiq
    original_test_mode =
      if Sidekiq::Testing.inline?
        :inline
      elsif Sidekiq::Testing.disabled?
        :disable
      else
        :fake
      end

    # Capybara's server handles browser requests on another thread, so a block-scoped
    # testing mode would not affect jobs enqueued by those requests.
    Sidekiq.testing!(:inline)

    begin
      yield
    ensure
      Sidekiq.testing!(original_test_mode)
    end
  end

  def with_inline_sidekiq(&block)
    activate_feature!(:disable_fetch_ip_info_for_authenticated_session_worker)

    SidekiqSpecHelpers.with_global_inline_sidekiq do
      # Disabling Prosopite here risks false negatives, but it avoids false
      # positives, so let's do it.
      Prosopite.pause(&block)
    end
  end
end
