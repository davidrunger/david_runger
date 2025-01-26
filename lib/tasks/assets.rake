namespace :assets do
  def run_logged_system_command(command, env_vars = {})
    puts(<<~LOG.squish)
      Running system command '#{AmazingPrint::Colors.blue(command)}'
      with ENV vars #{AmazingPrint::Colors.blue(env_vars.to_s)}...
    LOG
    if system(env_vars, command)
      puts '... success.'
    else
      puts '... failed.'
    end
  end

  def upload_zipped_assets(git_sha, directory_name)
    file_output_path = "tmp/#{directory_name}.zip"
    FileUtils.mkdir_p('tmp')
    system("cd public && zip -r ../#{file_output_path} #{directory_name} > /dev/null")

    Aws::S3::Resource.new(region: 'us-east-1').
      bucket('david-runger-test-uploads').
      object("compiled-assets/#{git_sha}/#{directory_name}.zip").
      put(body: File.read(file_output_path))

    system("rm #{file_output_path}")
  end

  desc 'Boot a server in development that serves assets in a production-like manner'
  task :production_asset_server do
    run_logged_system_command('rm -rf node_modules/')
    run_logged_system_command('rm -rf public/assets/ public/vite/ public/vite-admin/')
    run_logged_system_command('rm -f app/javascript/rails_assets/routes.js')
    run_logged_system_command('bin/rails build_js_routes', { 'DISABLE_SPRING' => '1' })
    run_logged_system_command('pnpm install')
    run_logged_system_command(
      'bin/vite build --force',
      {
        'NODE_ENV' => 'production',
      },
    )
    run_logged_system_command(
      'bin/vite build --force',
      {
        'NODE_ENV' => 'production',
        'VITE_RUBY_ENTRYPOINTS_DIR' => 'admin_packs',
        'VITE_RUBY_PUBLIC_OUTPUT_DIR' => 'vite-admin',
      },
    )
    run_logged_system_command(
      'bin/rails server',
      {
        'DISABLE_SPRING' => '1',
        'PRODUCTION_ASSET_CONFIG' => '1',
        'VITE_RUBY_AUTO_BUILD' => 'false',
      },
    )
  end

  desc 'Upload Vite assets to S3'
  task :upload_vite_assets do
    git_sha = ENV.fetch('GIT_REV')

    upload_zipped_assets(git_sha, 'vite')
    upload_zipped_assets(git_sha, 'vite-admin')
  end
end

Rake::Task['assets:precompile'].enhance(%w[build_js_routes]) do
  def download_s3_zip(git_sha, directory_name)
    s3_bucket.
      object("compiled-assets/#{git_sha}/#{directory_name}.zip").
      get(response_target: "tmp/#{directory_name}.zip")
  end

  git_sha = ENV.fetch('GIT_REV')
  raise('Could not determine git SHA!') if git_sha.empty?

  def download_s3_zips(git_sha)
    download_s3_zip(git_sha, 'vite')
    download_s3_zip(git_sha, 'vite-admin')
  end

  def s3_bucket
    @s3_bucket ||=
      Aws::S3::Resource.new(
        region: 'us-east-1',
        # NOTE: Here we are using the undocumented `unsigned_operations` feature
        # (subject to breaking changes) to request public resources in this
        # bucket without needing an AWS access key and secret.
        # https://github.com/aws/aws-sdk-ruby/issues/
        # 1149#issuecomment-2007175332
        unsigned_operations: [:get_object],
      ).bucket('david-runger-test-uploads')
  end

  begin
    Rails.logger.info("Attempting to fetch precompiled assets (git sha #{git_sha}).")
    download_s3_zips(git_sha)
  rescue Aws::S3::Errors::AccessDenied, Aws::S3::Errors::NoSuchKey => error
    # These errors can occur if there aren't precompiled assets available for the specified git sha,
    # e.g. if deploying manually via `git push` rather than via GitHub Actions. In this case, find
    # the most recent SHA for which there _are_ precompiled assets, and use that.
    Rails.logger.warn("Could not fetch precompiled assets for git sha #{git_sha}.")
    if (
      (use_fallback_until = ENV.fetch('USE_PRECOMPILED_ASSETS_FALLBACK_UNTIL', nil)) &&
        Time.current <= Time.zone.at(Integer(use_fallback_until))
    )
      Rails.error.report(error, context: { git_sha: })
      most_recent_object = s3_bucket.objects(prefix: 'compiled-assets/').max_by(&:last_modified)
      git_sha = most_recent_object.key.delete_prefix('compiled-assets/').remove(%r{/vite[^/]*\z})
      Rails.logger.info("Attempting to fetch fallback precompiled assets (git sha #{git_sha}).")
      download_s3_zips(git_sha)
    else
      raise
    end
  end

  FileUtils.rm_rf('public/vite/')
  FileUtils.rm_rf('public/vite-admin/')
  system('unzip -d public/ tmp/vite.zip')
  system('unzip -d public/ tmp/vite-admin.zip')
  FileUtils.rm('tmp/vite.zip')
  FileUtils.rm('tmp/vite-admin.zip')
end

if Rails.env.production?
  Rake::Task['assets:clean'].enhance do
    FileUtils.remove_dir('node_modules', true)
  end
end
