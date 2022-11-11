# frozen_string_literal: true

module JsonBroadcastable
  extend ActiveSupport::Concern

  module ClassMethods
    def broadcasts_json_to(channel, channel_target_proc)
      after_create_commit(
        -> { broadcast_json_to(channel, channel_target_proc, :created) },
      )

      after_update_commit(
        -> { broadcast_json_to(channel, channel_target_proc, :updated) },
      )

      after_destroy_commit(
        -> { broadcast_json_to(channel, channel_target_proc, :destroyed) },
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
      model: as_json,
    )
  end
end
