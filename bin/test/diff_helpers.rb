# frozen_string_literal: true

module DiffHelpers
  prepend MemoWise

  SPECIAL_RUBY_FILES = %w[
    .irbrc
    .pryrc
    Gemfile
  ].freeze

  private

  def file_changed?(filename)
    files_changed.include?(filename)
  end

  memo_wise \
  def db_schema_changed?
    file_changed?('db/schema.rb')
  end

  memo_wise \
  def diff
    ensure_master_is_present
    `git log master..HEAD --full-diff --source --format="" --unified=0 -p .
      | grep -Ev "^(diff |index |--- a/|\\+\\+\\+ b/|@@ )"`
  end

  memo_wise \
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

  memo_wise \
  def files_added_in?(directory)
    ensure_master_is_present
    `git diff --name-only --diff-filter=A master HEAD #{directory}`.rstrip.split("\n").any?
  end

  memo_wise \
  def files_changed
    ensure_master_is_present
    `git diff --name-only $(git merge-base HEAD master)`.rstrip.split("\n")
  end

  memo_wise \
  def files_with_css_changed?
    Dir['app/**/*.{css,scss,vue}'].intersect?(files_changed)
  end

  memo_wise \
  def files_with_js_changed?
    Dir['app/javascript/**/*.{js,ts,vue}'].intersect?(files_changed)
  end

  memo_wise \
  def haml_files_changed?
    Dir['app/**/*.haml'].intersect?(files_changed)
  end

  memo_wise \
  def rubocop_files_changed?
    files_changed.any? { |file| file.include?('rubocop') } # e.g. `.rubocop.yml`
  end

  memo_wise \
  def ruby_files_changed?
    ruby_files =
      Dir['*.rb'] +
      Dir.glob('*').select { File.directory?(_1) }.map do |directory|
        Dir["#{directory}/**/*.rb"] + Dir["#{directory}/**/*.rake"]
      end.flatten +
      SPECIAL_RUBY_FILES
    ruby_files.intersect?(files_changed)
  end
end
