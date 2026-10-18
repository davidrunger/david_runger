# percy-capybara returns the fetched dom.js as an ASCII-8BIT string. json >= 3.1.0
# rejects binary strings containing non-ASCII bytes during generation, so the
# snapshot fails with `"\xE2" from ASCII-8BIT to UTF-8`.
# Remove once percy-capybara forces the script to UTF-8 upstream.
if defined?(Capybara::Session)
  module PercyCapybaraUtf8Patch
    private

    def fetch_percy_dom
      super.dup.force_encoding(Encoding::UTF_8)
    end
  end

  Capybara::Session.prepend(PercyCapybaraUtf8Patch)
end
