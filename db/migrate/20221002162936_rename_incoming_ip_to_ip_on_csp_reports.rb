# frozen_string_literal: true

class RenameIncomingIpToIpOnCspReports < ActiveRecord::Migration[7.0]
  def change
    rename_column(:csp_reports, :incoming_ip, :ip)
  end
end
