# frozen_string_literal: true

class AddUserAgentToCspReports < ActiveRecord::Migration[7.0]
  def change
    add_column :csp_reports, :user_agent, :text
    CspReport.find_each { _1.update!(user_agent: '[not recorded]') }
    change_column_null :csp_reports, :user_agent, false
  end
end
