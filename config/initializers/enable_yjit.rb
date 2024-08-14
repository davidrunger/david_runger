# Enable YJIT on the server (for performance gains), but not on the worker (for memory savings).
if defined?(RubyVM::YJIT.enable) && (defined?(Rails::Server) || ENV.key?('CI'))
  Rails.application.config.after_initialize do
    RubyVM::YJIT.enable
  end
end
