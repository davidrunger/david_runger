# frozen_string_literal: true

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
