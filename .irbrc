# frozen_string_literal: true

home_irbrc_path = "#{Dir.home}/.irbrc.rb"
# this file is not expected to be there in production
load(home_irbrc_path) if File.exist?(home_irbrc_path)

IRB.conf[:USE_AUTOCOMPLETE] = false
