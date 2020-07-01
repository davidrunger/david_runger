# frozen_string_literal: true

class TouchActivityAt
  prepend ApplicationWorker

  def perform(user_id, request_time_as_float)
    user = User.find_by(id: user_id)

    if user.blank?
      Rails.logger.info("User #{user_id} was not found to update last_activity_at")
      return
    end

    request_time = Time.zone.at(request_time_as_float)
    if user.last_activity_at.blank? || (request_time > user.last_activity_at)
      user.update!(last_activity_at: request_time)
    end
  end
end
