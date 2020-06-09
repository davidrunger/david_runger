# frozen_string_literal: true

# Emit an event when an IP address is banned via Rack::Attack's fail2ban system.
# (Rack::Attack emits other events like this already, but not one specifically in this scenario.)
module InstrumentFail2BanEventMonkeypatch
  def ban!(discriminator, _bantime)
    return_value = super
    ActiveSupport::Notifications.instrument('fail2banned.rack_attack', discriminator: discriminator)
    return_value
  end
end

Rack::Attack::Fail2Ban.singleton_class.prepend(InstrumentFail2BanEventMonkeypatch)
