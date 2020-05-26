# frozen_string_literal: true

def convert_weight_logs_to_general_logs
  users_with_weight_logs = User.joins(:weight_logs).distinct
  users_with_weight_logs.find_each do |user|
    weight_log = user.logs.create!(name: 'Weight')
    weight_log.log_inputs.create!(public_type: 'integer', label: 'Weight')
    user.weight_logs.find_each do |weight_log_entry|
      weight_log.log_entries.create!(
        created_at: weight_log_entry.created_at,
        data: { Weight: weight_log_entry.weight },
      )
    end
  end
end
