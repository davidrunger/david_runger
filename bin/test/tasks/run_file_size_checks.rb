# frozen_string_literal: true

require Rails.root.join('lib/track_asset_sizes.rb')

class Test::Tasks::RunFileSizeChecks < Pallets::Task
  extend Memoist
  include Test::TaskHelpers

  # file size constraints in kilobytes
  CONSTRAINTS = {
    'charts*.js' => (288..298),
    'check_ins*.css' => (10..15),
    'check_ins*.js' => (170..180),
    'check_ins_index*.js' => (5..15),
    'groceries*.css' => (100..110),
    'groceries*.js' => (391..401),
    'home*.css' => (0..10),
    'home*.js' => (130..140),
    'logs*.css' => (100..110),
    'logs*.js' => (770..780),
    'marriage*.js' => (10..20),
    'quizzes*.js' => (105..115),
    'styles*.css' => (15..25),
    'turbo*.js' => (70..80),
    'workout*.css' => (100..110),
    'workout*.js' => (385..395),
  }.freeze

  def run
    puts("Running '#{self.class.name.yellow}' ...")

    time =
      Benchmark.measure do
        check_for_mismatched_files
        check_for_file_size_violations

        puts('Bundle sizes (in kilobytes):')
        pp(assets_and_size_in_kb)
      end.real

    if unspecified_files.none? && nonexistent_files.none? && file_size_violations.none?
      record_success_and_log_message("'#{self.class.name}' succeeded (took #{time.round(3)}).")
    end
  end

  private

  memoize \
  def tracker
    TrackAssetSizes.new
  end

  memoize \
  def assets_and_size_in_kb
    tracker.
      track_all_asset_sizes(dry_run: true).
      transform_values { _1.fdiv(1024).round(2) }
  end

  memoize \
  def file_size_violations
    assets_and_size_in_kb.reject do |asset_name, file_size_in_kb|
      constraint = CONSTRAINTS[asset_name]
      constraint && constraint.cover?(file_size_in_kb)
    end
  end

  memoize \
  def readable_file_size_violations
    file_size_violations.map do |file_name, actual_size|
      constraint = CONSTRAINTS[file_name]
      next if constraint.nil?

      <<~LOG.squish
        `#{file_name}` is supposed to be #{constraint.first}-#{constraint.last} kB,
        but it is #{actual_size} kB
      LOG
    end.join(', ')
  end

  memoize \
  def unspecified_files
    assets_and_size_in_kb.keys - CONSTRAINTS.keys
  end

  memoize \
  def nonexistent_files
    CONSTRAINTS.keys - assets_and_size_in_kb.keys
  end

  def check_for_file_size_violations
    if file_size_violations.any?
      file_size_violations.each do |glob, actual_file_size|
        record_failed_command("#{glob} size #{actual_file_size} is not in #{CONSTRAINTS[glob]}")
      end

      record_failure_and_log_message(<<~LOG.squish)
        There are file size violations in #{self.class.name}! #{readable_file_size_violations}.
      LOG
    end
  end

  def check_for_mismatched_files
    if unspecified_files.any?
      record_failed_command("missing file size constraint(s) for #{unspecified_files}")
      record_failure_and_log_message(<<~LOG.squish)
        There are asset(s) (#{unspecified_files}) that lack
        file size constraints specified in #{self.class.name}!
      LOG
    end

    if nonexistent_files.any?
      record_failed_command("missing file(s) #{nonexistent_files}")
      record_failure_and_log_message(<<~LOG.squish)
        There are assets (#{nonexistent_files}) specified in
        #{self.class.name} that don't correspond to actual files!
      LOG
    end
  end
end
