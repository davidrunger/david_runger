# frozen_string_literal: true

# :nocov:
if (
  Rails.env.local? &&
    ENV['SKIP_GITHOOKS_CHECK'].blank? &&
    ENV['CI'].blank? &&
    `git config core.hooksPath`.strip != 'bin/githooks'
)
  $stderr.puts(<<~ERROR)
    You have not configured the git hooks for this repo! To do so, run:
        git config core.hooksPath bin/githooks
    Or, if you must, you can put SKIP_GITHOOKS_CHECK=1 in your .env file.
  ERROR

  exit(1) # rubocop:disable Rails/Exit
end
# :nocov:
