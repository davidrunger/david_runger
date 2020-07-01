# frozen_string_literal: true

class EnablePgStatStatementsExtension < ActiveRecord::Migration[5.1]
  def up
    ApplicationRecord.connection.execute('CREATE EXTENSION IF NOT EXISTS pg_stat_statements;')
  end

  def down
    ApplicationRecord.connection.execute('DROP EXTENSION IF EXISTS pg_stat_statements;')
  end
end
