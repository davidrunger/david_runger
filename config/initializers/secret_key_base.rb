# frozen_string_literal: true

DavidRunger::Application.config.secret_key_base = ENV.fetch('SECRET_KEY_BASE', nil)
