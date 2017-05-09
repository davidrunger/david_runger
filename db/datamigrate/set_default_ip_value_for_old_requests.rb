def set_default_ip_value_for_old_requests
  Request.update_all(ip: 'NOT_RECORDED')
end
