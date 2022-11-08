# frozen_string_literal: true

module JsonBroadcastable
  extend ActiveSupport::Concern

  module ClassMethods
    def broadcasts_json_to(channel, channel_target)
      after_create_commit(
        -> { broadcast_json_to(channel, channel_target, :created) },
      )

      after_update_commit(
        -> { broadcast_json_to(channel, channel_target, :updated) },
      )

      after_destroy_commit(
        -> { broadcast_json_to(channel, channel_target, :destroyed) },
      )
    end
  end

  private

  def broadcast_json_to(channel, channel_target, action)
    channel.broadcast_to(
      public_send(channel_target),
      action:,
      model: ActiveModel::Serializer.serializer_for(self).new(self).as_json,
    )
  end
end
