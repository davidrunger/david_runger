# frozen_string_literal: true

module DiffHelpers
  extend Memoist

  SPECIAL_RUBY_FILES = %w[
    .irbrc
    .pryrc
    Gemfile
  ].freeze

  private

  memoize \
  def db_schema_changed?
    files_changed.include?('db/schema.rb')
  end

  memoize \
  def diff
    ensure_master_is_present
    `git log master..HEAD --full-diff --source --format="" --unified=0 -p . \
      | grep -Ev "^(diff |index |--- a/|\\+\\+\\+ b/|@@ )"`
  end

  memoize \
  def diff_mentions?(phrase)
    diff.match?(%r{#{phrase}}i)
  end

  def ensure_master_is_present
    if !system('git log -1 --pretty="%H" master > /dev/null 2>&1')
      puts('`master` branch is not present; fetching it now...')
      system('git fetch origin master:master --depth=1', exception: true)
      puts('Done fetching origin master branch.')
    end
  end

  memoize \
  def files_added_in?(directory)
    ensure_master_is_present
    `git diff --name-only --diff-filter=A master HEAD #{directory}`.rstrip.split("\n").any?
  end

  memoize \
  def files_changed
    ensure_master_is_present
    `git diff --name-only $(git merge-base HEAD master)`.rstrip.split("\n")
  end

  memoize \
  def files_with_css_changed?
    (Dir['app/**/*.{css,scss,vue}'] & files_changed).any?
  end

  memoize \
  def files_with_js_changed?
    (Dir['app/javascript/**/*.{js,vue}'] & files_changed).any?
  end

  memoize \
  def haml_files_changed?
    (Dir['app/**/*.haml'] & files_changed).any?
  end

  memoize \
  def rubocop_files_changed?
    files_changed.any? { |file| file.include?('rubocop') } # e.g. `.rubocop.yml`
  end

  memoize \
  def ruby_files_changed?
    ruby_files =
      Dir['*.rb'] +
      Dir.glob('*').select { File.directory?(_1) }.map do |directory|
        Dir["#{directory}/**/*.rb"] + Dir["#{directory}/**/*.rake"]
      end.flatten +
      SPECIAL_RUBY_FILES
    (ruby_files & files_changed).any?
  end
end
