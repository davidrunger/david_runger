# frozen_string_literal: true

# https://github.com/rails/spring-watcher-listen/issues/15#issuecomment-567603693
module SpringWatcherListenIgnorer
  def start
    # :nocov:
    super
    listener.ignore(%r{
      ^(
      .bundle/
      .github/
      coverage/|
      db/|
      log/|
      node_modules/|
      personal/|
      spec/fixtures/|
      tmp/
      )
    }x)
    # :nocov:
  end
end
Spring::Watcher::Listen.prepend(SpringWatcherListenIgnorer)

Spring.watch(*%w[.ruby-version .rbenv-vars tmp/restart.txt tmp/caching-dev.txt])
