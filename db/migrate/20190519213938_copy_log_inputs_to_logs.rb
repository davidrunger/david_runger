# frozen_string_literal: true

require Rails.root.join('db', 'datamigrate', 'copy_log_inputs_to_logs.rb')

class CopyLogInputsToLogs < ActiveRecord::Migration[5.2]
  def change
    copy_log_inputs_to_logs!
  end
end
