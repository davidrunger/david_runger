# frozen_string_literal: true

class ApplicationAction < ActiveActions::Base
  include Rails.application.routes.url_helpers
end
