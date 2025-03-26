Aws.config.update(
  credentials: Aws::Credentials.new(
    ENV['AWS_ACCESS_KEY_ID'].presence,
    ENV['AWS_SECRET_ACCESS_KEY'].presence,
  ),
)
