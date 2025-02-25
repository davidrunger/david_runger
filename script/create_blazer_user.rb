require_relative '../config/environment'

require 'uri'

url = ENV.fetch('BLAZER_DATABASE_URL')
uri = URI.parse(url)
username = uri.user
password = uri.password
database_name = uri.path.delete_prefix('/')

# rubocop:disable Rails/SquishedSQLHeredocs
ApplicationRecord.connection.execute(<<~SQL)
  DO $$
  BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '#{username}') THEN
      CREATE ROLE #{username} LOGIN PASSWORD '#{password}';
    END IF;
  END;
  $$;

  GRANT CONNECT ON DATABASE #{database_name} TO #{username};
  GRANT USAGE ON SCHEMA public TO #{username};
  GRANT SELECT ON ALL TABLES IN SCHEMA public TO #{username};
  ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO #{username};
SQL
# rubocop:enable Rails/SquishedSQLHeredocs
