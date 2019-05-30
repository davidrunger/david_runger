# frozen_string_literal: true

Browser.modern_rules.clear
Browser.modern_rules << ->(browser) { !browser.ie? }
