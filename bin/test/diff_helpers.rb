# frozen_string_literal: true

module DiffHelpers
  extend Memoist

  private

  memoize \
  def db_schema_changed?
    files_changed.include?('db/schema.rb')
  end

  memoize \
  def diff
    `git log master..HEAD --full-diff --source --format="" --unified=0 -p . \
      | grep -Ev "^(diff |index |--- a/|\\+\\+\\+ b/|@@ )"`
  end

  memoize \
  def diff_mentions_rubocop?
    diff.match?(%r{rubocop}i)
  end

  memoize \
  def files_changed
    if !system('git log -1 --pretty="%H" master > /dev/null 2>&1')
      puts('`master` branch is not present; fetching it now...')
      `git fetch origin master:master --depth=1`
      puts('Done fetching origin master branch.')
    end

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
        Dir["#{directory}/**/*.rb"]
      end.flatten
    (ruby_files & files_changed).any?
  end
end
