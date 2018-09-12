Browser.modern_rules.clear
Browser.modern_rules << ->(browser) { !browser.ie? }
