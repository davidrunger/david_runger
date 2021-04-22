# frozen_string_literal: true

def copy_log_inputs_to_logs!
  LogInput.find_each do |log_input|
    log = log_input.log

    data_type =
      case log_input.type
      when 'LogInputs::DurationLogInput'
        'duration'
      when 'LogInputs::IntegerLogInput'
        'number'
      when 'LogInputs::TextLogInput'
        'text'
      end

    log.update!(data_type: data_type, data_label: log_input.label)
  end
end
