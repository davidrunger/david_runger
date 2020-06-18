# frozen_string_literal: true

# disable ActiveModelSerializers logging
ActiveSupport::Notifications.unsubscribe(ActiveModelSerializers::Logging::RENDER_EVENT)
