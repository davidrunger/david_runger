# frozen_string_literal: true

class ApplicationCable::Channel < ActionCable::Channel::Base
  def authorize!(record, policy_query)
    policy_klass = Pundit::PolicyFinder.new(record).policy!
    policy_instance = policy_klass.new(current_user, record)

    if !policy_instance.public_send(policy_query)
      raise(Pundit::NotAuthorizedError, <<~ERROR.squish)
        #{policy_klass} says that #{current_user.class}:#{current_user&.id.inspect}
        is not authorized to #{policy_query} #{record.class}:#{record.id}
      ERROR
    end
  end
end
