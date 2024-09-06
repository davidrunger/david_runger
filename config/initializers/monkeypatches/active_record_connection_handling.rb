if Rails.env.test?
  # Code being patched:
  # https://github.com/rails/rails/blob/v7.2.1/activerecord/lib/active_record/connection_handling.rb#L259-L281
  module Runger::ConnectionHandlingMonkeypatch
    def connection
      pool = connection_pool
      check_calling_connection_allowed
      # :nocov:
      if pool.permanent_lease?
        pool.lease_connection
      else
        pool.active_connection
      end
      # :nocov:
    end

    def check_calling_connection_allowed
      case ActiveRecord.permanent_connection_checkout
      when :deprecated
        # :nocov:
        ActiveRecord.deprecator.warn(<<~MESSAGE)
          Called deprecated `ActiveRecord::Base.connection` method.

          Either use `with_connection` or `lease_connection`.
        MESSAGE
        # :nocov:
      when :disallowed
        raise(ActiveRecord::ActiveRecordError, <<~MESSAGE)
          Called deprecated `ActiveRecord::Base.connection` method.

          Either use `with_connection` or `lease_connection`.
        MESSAGE
      end
    end
  end

  ActiveSupport.on_load(:active_record) do
    ActiveRecord::ConnectionHandling.prepend(Runger::ConnectionHandlingMonkeypatch)
  end
end
