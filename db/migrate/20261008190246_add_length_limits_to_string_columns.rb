class AddLengthLimitsToStringColumns < ActiveRecord::Migration[8.1]
  def up
    change_table :csp_reports, bulk: true do |t|
      t.change :document_uri, :string, limit: 2048
      t.change :violated_directive, :string, limit: 1024
      t.change :original_policy, :string, limit: 8192
      t.change :referrer, :string, limit: 2048
      t.change :blocked_uri, :string, limit: 2048
      t.change :user_agent, :string, limit: 1024
    end

    change_table :events, bulk: true do |t|
      t.change :type, :string, limit: 100
      t.change :user_agent, :string, limit: 1024
    end

    change_column :ip_blocks, :ip, :string, limit: 45
  end

  def down
    raise(ActiveRecord::IrreversibleMigration)
  end
end
