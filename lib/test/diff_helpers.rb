module DiffHelpers
  prepend Memoization

  SPECIAL_RUBY_FILES = %w[
    .irbrc
    .pryrc
    Gemfile
  ].freeze

  private

  def file_changed?(filename)
    files_changed.include?(filename)
  end

  memoize \
  def db_schema_changed?
    file_changed?('db/schema.rb')
  end

  memoize \
  def dotfile_changed?
    files_changed.any? { _1.match?(/(^|\/)\./) }
  end

  memoize \
  def diff
    ensure_master_is_present
    `git log main..HEAD --full-diff --source --format="" --unified=0 -p . \
      | grep -Ev "^(diff |index |--- a/|\\+\\+\\+ b/|@@ )"`
  end

  memoize \
  def diff_mentions?(phrase)
    diff.match?(%r{#{phrase}}i)
  end

  def ensure_master_is_present
    if !system('git log -1 --pretty="%H" main > /dev/null 2>&1')
      puts('`main` branch is not present; fetching it now...')
      system('git fetch origin main:main --depth=1', exception: true)
      puts('Done fetching origin main branch.')
    end
  end

  memoize \
  def files_added_in?(directory)
    ensure_master_is_present
    `git diff --name-only --diff-filter=A main HEAD #{directory}`.rstrip.split("\n").any?
  end

  memoize \
  def files_changed
    ensure_master_is_present
    `git diff --name-only $(git merge-base HEAD main)`.rstrip.split("\n")
  end

  memoize \
  def file_extensions_changed
    files_changed.filter_map do |file_name|
      file_name.include?('.') && file_name.split('.').last
    end.uniq.sort
  end

  memoize \
  def all_changed_file_extensions_are_among?(file_extensions)
    (file_extensions_changed - file_extensions).empty?
  end

  memoize \
  def files_with_css_changed?
    Dir['app/**/*.{css,scss,vue}'].intersect?(files_changed)
  end

  memoize \
  def files_with_js_changed?
    Dir['app/javascript/**/*.{js,ts,vue}'].intersect?(files_changed)
  end

  memoize \
  def haml_files_changed?
    Dir['app/**/*.haml'].intersect?(files_changed)
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
    ruby_files.intersect?(files_changed)
  end
end
