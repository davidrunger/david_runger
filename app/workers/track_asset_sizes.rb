# frozen_string_literal: true

class TrackAssetSizes
  prepend ApplicationWorker

  BUNDLE_SUFFIXES = ['', '.br', '.gz'].freeze
  CSS_BUNDLE_GLOBS = %w[
    groceries*.css
    home*.css
    logs*.css
    styles*.css
    workout*.css
  ].map(&:freeze).freeze
  JS_BUNDLE_GLOBS = %w[
    charts*.js
    groceries*.js
    home*.js
    logs*.js
    quizzes*.js
    turbo*.js
    workout*.js
  ].map(&:freeze).freeze

  class << self
    extend Memoist

    memoize \
    def all_globs
      css_globs + js_globs
    end

    memoize \
    def css_globs
      CSS_BUNDLE_GLOBS.map do |bundle_glob|
        BUNDLE_SUFFIXES.map do |bundle_suffix|
          "#{bundle_glob}#{bundle_suffix}"
        end
      end.flatten
    end

    memoize \
    def js_globs
      JS_BUNDLE_GLOBS.map do |bundle_glob|
        BUNDLE_SUFFIXES.map do |bundle_suffix|
          "#{bundle_glob}#{bundle_suffix}"
        end
      end.flatten
    end
  end

  def perform
    self.class.css_globs.each do |glob|
      track_filesize(glob, "public/packs/#{glob}")
    end

    self.class.js_globs.each do |glob|
      track_filesize(glob, "public/packs/js/#{glob}")
    end
  end

  private

  def track_filesize(glob, full_glob)
    filesize_string = `wc -c < $(ls #{full_glob})`.strip
    filesize = Integer(filesize_string)
    RedisTimeseries[glob].add(filesize)
  end
end
