# frozen_string_literal: true

# This monkeypatch can probably be removed once Sidekiq 6.1 has been released.
# See https://github.com/mperham/sidekiq/issues/4591 .
module SuppressWarningAboutRedisExistsMonkeypatch
  WARNING_MESSAGE = '`Redis#exists(key)` will return an Integer in redis-rb 4.3'

  def warn(*args)
    message = args.first.to_s
    return if message.include?(WARNING_MESSAGE)

    super
  end
end

::Kernel.singleton_class.prepend(SuppressWarningAboutRedisExistsMonkeypatch)
