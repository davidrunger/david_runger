# frozen_string_literal: true

# The name of this file uses lexicographical ordering. See:
# https://stackoverflow.com/a/38927158/4009384 . To determine a new filename for
# insertion, see: https://runkit.com/davidrunger/667b2a5707d6c60008d1fe66 .

# :nocov:
if (
  Rails.env.local? &&
    ENV['SKIP_GITHOOKS_CHECK'].blank? &&
    ENV['CI'].blank? &&
    `git config core.hooksPath`.strip != 'bin/githooks'
)
  $stderr.puts(AmazingPrint::Colors.red(<<~ERROR))
    You have not configured the git hooks for this repo! To do so, run:

      #{AmazingPrint::Colors.blue('git config core.hooksPath bin/githooks')}
  ERROR

  $stderr.puts(AmazingPrint::Colors.red(<<~ERROR))
    Or, if you must, you can set `SKIP_GITHOOKS_CHECK=1` in `.env.development.local`.
  ERROR

  exit(1) # rubocop:disable Rails/Exit
end
# :nocov:
