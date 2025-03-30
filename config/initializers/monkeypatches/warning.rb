# In test, this monkeypatch stores warnings in a global `$warnings` variable (if
# it is defined). This variable will be set before each RSpec test and checked
# afterward, to make sure that no warnings were printed. If they were, then we
# will fail the test. This ensures that warnings are caught by CI, rather than
# being logged without anyone noticing (and fixing) them.

if Rails.env.test?
  module StoredWarnings
    mattr_accessor :warnings

    def warn(message, *_args, **_kwargs)
      # :nocov:
      if StoredWarnings.warnings.respond_to?(:<<)
        StoredWarnings.warnings << message
      end

      super
      # :nocov:
    end
  end

  Warning.prepend(StoredWarnings)
end
