# frozen_string_literal: true

class ApplicationCable::Channel < ActionCable::Channel::Base
  class MessageOriginator
    def initialize(user, channel)
      @user = user
      @channel = channel
    end

    def broadcast_to(model, message)
      message[:originating_user_id] = @user.id
      @channel.broadcast_to(model, message)
    end
  end

  class << self
    def from(user)
      MessageOriginator.new(user, self)
    end
  end

  def authorize!(record, policy_query)
    policy_klass = Pundit::PolicyFinder.new(record).policy!
    policy_instance = policy_klass.new(current_user, record)

    if !policy_instance.public_send(policy_query)
      raise(Pundit::NotAuthorizedError, <<~ERROR.squish)
        #{policy_klass} says that #{current_user.class}:#{current_user.id}
        is not authorized to #{policy_query} #{record.class}:#{record.id}
      ERROR
    end
  end
end
