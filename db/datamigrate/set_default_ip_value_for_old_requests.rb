# frozen_string_literal: true

def set_default_ip_value_for_old_requests
  # rubocop:disable Rails/SkipsModelValidations
  Request.update_all(ip: 'NOT_RECORDED')
  # rubocop:enable Rails/SkipsModelValidations
end
