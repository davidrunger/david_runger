# Enable YJIT on the server (for performance gains), but not on the worker (for memory savings).
if defined?(RubyVM::YJIT.enable)
  Rails.application.config.after_initialize do
    if defined?(Rails::Server)
      RubyVM::YJIT.enable
    end
  end
end
