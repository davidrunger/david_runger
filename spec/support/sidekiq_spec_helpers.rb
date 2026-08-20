module SidekiqSpecHelpers
  # NOTE: This is a workaround for the issue mentioned here
  # https://github.com/sidekiq/sidekiq/issues/ 6069#issuecomment-1755344641 .
  def with_inline_sidekiq(&block)
    activate_feature!(:disable_fetch_ip_info_for_authenticated_session_worker)

    Sidekiq.testing!(:inline) do
      # Disabling Prosopite here risks false negatives, but it avoids false
      # positives, so let's do it.
      Prosopite.pause(&block)
    end
  end
end
