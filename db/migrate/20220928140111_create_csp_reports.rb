# frozen_string_literal: true

class CreateCspReports < ActiveRecord::Migration[7.0]
  def change
    create_table :csp_reports do |t|
      t.string :document_uri, null: false
      t.string :violated_directive, null: false
      t.string :original_policy, null: false
      t.string :incoming_ip, null: false
      t.string :referrer
      t.string :blocked_uri

      t.timestamps
    end
  end
end
