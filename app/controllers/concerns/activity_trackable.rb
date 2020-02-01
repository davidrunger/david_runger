# frozen_string_literal: true

module ActivityTrackable
  extend ActiveSupport::Concern

  included do
    before_action :enqueue_touch_activity_at_worker, if: -> { current_user.present? }
  end

  private

  def enqueue_touch_activity_at_worker
    TouchActivityAt.perform_async(current_user.id, Float(@request_time))
  end
end
