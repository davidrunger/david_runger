class AuthenticatedSessionDecorator < Draper::Decorator
  include UserAgentDecoratable

  delegate_all

  def initial_client
    user_agent_description(initial_user_agent)
  end

  def latest_client
    user_agent_description(latest_user_agent)
  end

  def first_seen
    h.l(created_at, format: :minute)
  end

  def last_active
    h.l(last_active_at, format: :minute)
  end
end
