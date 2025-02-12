class Test::Tasks::UploadViteAssets < Pallets::Task
  include Test::TaskHelpers

  def run
    if ENV.fetch('CI', nil) == 'true' && ENV.fetch('GITHUB_REF_NAME') == 'main'
      execute_rake_task(
        'assets:upload_vite_assets',
        log_stdout_only_on_failure: true,
      )
    else
      record_success_and_log_message(<<~LOG)
        Not running in CI on main; skipping assets:upload_vite_assets.
      LOG
    end
  end
end
