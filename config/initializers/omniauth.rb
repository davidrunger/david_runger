# frozen_string_literal: true

# avoid OmniAuth output being sent to STDOUT during tests
OmniAuth.config.logger = Rails.logger
