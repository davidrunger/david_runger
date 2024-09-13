if Rails.env.local?
  # Code being patched:
  # https://github.com/rails/rails/blob/v7.2.1/activerecord/lib/active_record/connection_handling.rb#L259-L281
  module DavidRunger::ConnectionHandlingMonkeypatch
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
      unless $PROGRAM_NAME.match?(/\bdatabase_consistency\b/) || caller.any?(/\bimmigrant\b/)
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
  end

  ActiveSupport.on_load(:active_record) do
    ActiveRecord::ConnectionHandling.prepend(DavidRunger::ConnectionHandlingMonkeypatch)
  end
end
