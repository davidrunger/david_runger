class EnablePgStatStatementsExtensionV2 < ActiveRecord::Migration[8.0]
  def up
    ApplicationRecord.connection.execute('CREATE EXTENSION pg_stat_statements;')
  end

  def down
    ApplicationRecord.connection.execute('DROP EXTENSION pg_stat_statements;')
  end
end
