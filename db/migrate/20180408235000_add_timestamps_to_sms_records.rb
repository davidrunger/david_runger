# frozen_string_literal: true

require Rails.root.join('db/datamigrate/set_timestamps_for_old_sms_records')

class AddTimestampsToSmsRecords < ActiveRecord::Migration[5.2]
  def up
    add_column :sms_records, :created_at, :datetime
    add_column :sms_records, :updated_at, :datetime
    set_timestamps_for_old_sms_records
    change_column :sms_records, :created_at, :datetime, null: false
    change_column :sms_records, :updated_at, :datetime, null: false
  end

  def down
    remove_column :sms_records, :created_at
    remove_column :sms_records, :updated_at
  end
end
