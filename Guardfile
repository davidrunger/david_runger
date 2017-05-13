::Guard::TARGET_SPEC_FILE ||= ENV['GUARDED_FILE']

guard :espect, cmd: 'spring rspec', all_on_start: true do
  watch(%r{^(app|config|lib|spec)/.+\.rb$}) { ::Guard::TARGET_SPEC_FILE }
end
