class AddForeignKeysForBlazerTables < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :blazer_audits, :blazer_queries, column: :query_id
    add_foreign_key :blazer_audits, :admin_users, column: :user_id
    add_foreign_key :blazer_checks, :admin_users, column: :creator_id
    add_foreign_key :blazer_checks, :blazer_queries, column: :query_id
    add_foreign_key :blazer_dashboard_queries, :blazer_dashboards, column: :dashboard_id
    add_foreign_key :blazer_dashboard_queries, :blazer_queries, column: :query_id
    add_foreign_key :blazer_dashboards, :admin_users, column: :creator_id
    add_foreign_key :blazer_queries, :admin_users, column: :creator_id
  end
end
