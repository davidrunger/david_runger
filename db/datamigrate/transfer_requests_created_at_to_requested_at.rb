def transfer_requests_created_at_to_requested_at
  ActiveRecord::Base.connection.execute(<<~SQL.squish)
    UPDATE requests SET requested_at = created_at
  SQL
end
