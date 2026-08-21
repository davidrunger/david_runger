home_irbrc_path = "#{Dir.home}/.irbrc.rb"
# this file is not expected to be there in production
if File.exist?(home_irbrc_path)
  load(home_irbrc_path)
end

IRB.conf[:USE_AUTOCOMPLETE] = false
