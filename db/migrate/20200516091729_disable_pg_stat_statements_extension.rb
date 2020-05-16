# frozen_string_literal: true

class DisablePgStatStatementsExtension < ActiveRecord::Migration[6.1]
  def up
    ApplicationRecord.connection.execute('DROP EXTENSION IF EXISTS pg_stat_statements CASCADE;')
  end

  def down
    ApplicationRecord.connection.execute('CREATE EXTENSION IF NOT EXISTS pg_stat_statements;')
  end
end
