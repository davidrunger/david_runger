class SaveRequest::StashedDataManager
  prepend Memoization

  def initialize(request_id)
    @request_id = request_id
  end

  memoize \
  def stashed_data
    initial_stashed_data.merge(final_stashed_data)
  end

  memoize \
  def initial_request_data_redis_key
    "request_data:#{@request_id}:initial"
  end

  memoize \
  def initial_stashed_json
    $redis_pool.with { |conn| conn.call('get', initial_request_data_redis_key) }
  end

  memoize \
  def initial_stashed_data
    JSON.parse(initial_stashed_json)
  end

  memoize \
  def final_request_data_redis_key
    "request_data:#{@request_id}:final"
  end

  memoize \
  def final_stashed_json
    $redis_pool.with { |conn| conn.call('get', final_request_data_redis_key) }
  end

  memoize \
  def final_stashed_data
    JSON.parse(final_stashed_json)
  end

  def delete_request_data
    $redis_pool.with do |conn|
      conn.call('del', initial_request_data_redis_key, final_request_data_redis_key)
    end
  end
end
