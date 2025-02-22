module JsonBroadcastable
  extend ActiveSupport::Concern

  module ClassMethods
    def broadcasts_json_to(channel, channel_target_proc, unless: nil)
      unless_proc = binding.local_variable_get(:unless) || -> { false }

      after_create_commit(
        -> { broadcast_json_to(channel, channel_target_proc, :created) },
        unless: unless_proc,
      )

      after_update_commit(
        -> { broadcast_json_to(channel, channel_target_proc, :updated) },
        unless: unless_proc,
      )

      after_destroy_commit(
        -> { broadcast_json_to(channel, channel_target_proc, :destroyed) },
        unless: unless_proc,
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
