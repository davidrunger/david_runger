# frozen_string_literal: true

def destroy_requests_without_user_agent
  Request.where(user_agent: nil).delete_all
end
