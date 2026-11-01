require 'prosopite/middleware/rack'
Rails.configuration.middleware.use(Prosopite::Middleware::Rack)

Rails.application.config.after_initialize do
  if Rails.env.production?
    # simplecov:disable
    Prosopite.sample_rate = 0.01
    Prosopite.custom_logger = Class.new do
      def warn(message)
        Rails.error.report(
          Error.new(Prosopite::NPlusOneQueriesError, message),
          severity: :warning,
        )
      end
    end.new
    # simplecov:enable
  else
    Prosopite.rails_logger = true
    Prosopite.raise = true
    Prosopite.display_query_count = true
    Prosopite.display_max_n_queries = 1
  end
end
