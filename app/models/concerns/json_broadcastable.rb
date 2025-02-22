module JsonBroadcastable
  extend ActiveSupport::Concern

  module ClassMethods
    def broadcasts_json_to(channel, channel_target_proc, unless_for_destroyed: nil)
      after_create_commit(
        -> { broadcast_json_to(channel, channel_target_proc, :created) },
      )

      after_update_commit(
        -> { broadcast_json_to(channel, channel_target_proc, :updated) },
      )

      after_destroy_commit(
        -> { broadcast_json_to(channel, channel_target_proc, :destroyed) },
        unless: unless_for_destroyed || -> { false },
      )
    end
  end

  private

  def broadcast_json_to(channel, channel_target_proc, action)
    channel_target = channel_target_proc.call(self)
    return if channel_target.blank?

    channel.broadcast_to(
      channel_target,
      action:,
      acting_browser_uuid: Current.browser_uuid,
      model: as_json,
    )
  end
end
