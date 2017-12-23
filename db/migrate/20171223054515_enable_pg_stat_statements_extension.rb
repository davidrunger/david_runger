class EnablePgStatStatementsExtension < ActiveRecord::Migration[5.1]
  def up
    ApplicationRecord.connection.execute('CREATE EXTENSION pg_stat_statements;')
  end

  def down
    ApplicationRecord.connection.execute('DROP EXTENSION pg_stat_statements;')
  end
end
