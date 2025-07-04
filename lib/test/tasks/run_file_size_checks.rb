require Rails.root.join('app/poros/track_asset_sizes.rb')

class Test::Tasks::RunFileSizeChecks < Pallets::Task
  prepend Memoization
  include Test::TaskHelpers

  # file size constraints in kilobytes
  CONSTRAINTS = {
    'charts*.js' => (295..305),
    'check_ins*.css' => (10..15),
    'check_ins*.js' => (197..207),
    'check_ins_index*.js' => (5..15),
    'ci_step_gantt_charts*.js' => (806..816),
    'comments*.css' => (0..10),
    'comments*.js' => (335..345),
    'copy_to_clipboard*.css' => (0..10),
    'copy_to_clipboard*.js' => (2..12),
    'emoji_picker*.css' => (8..18),
    'emoji_picker*.js' => (337..347),
    'google_sign_in_button*.js' => (1..11),
    'groceries*.css' => (48..58),
    'groceries*.js' => (303..313),
    'home*.css' => (13..23),
    'home*.js' => (252..262),
    'logs*.css' => (101..111),
    'logs*.js' => (823..833),
    'model_graph*.js' => (623..633),
    'model_graph*.css' => (2..12),
    'quizzes*.js' => (123..133),
    'styles*.css' => (14..24),
    'turbo*.js' => (90..100),
    'ujs*.js' => (10..20),
    'vue_playground*.css' => (0..10),
    'vue_playground*.js' => (72..82),
    'workout*.css' => (41..51),
    'workout*.js' => (231..241),
  }.freeze

  def run
    puts("Running '#{AmazingPrint::Colors.yellow(self.class.name)}' ...")

    time =
      Benchmark.measure do
        check_for_mismatched_files
        check_for_file_size_violations

        puts("Bundle sizes (in kilobytes): #{assets_and_size_in_kb.inspect}")
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
      transform_values { it.fdiv(1024).round(2) }
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
