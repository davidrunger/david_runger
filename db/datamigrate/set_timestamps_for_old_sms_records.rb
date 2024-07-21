def set_timestamps_for_old_sms_records
  current_time = Time.current
  SmsRecord.find_each do |sms_record|
    sms_record.update!(created_at: current_time, updated_at: current_time)
  end
end
