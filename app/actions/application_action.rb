# frozen_string_literal: true

class ApplicationAction < RungerActions::Base
  include Rails.application.routes.url_helpers
end
