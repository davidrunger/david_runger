module JsonPrioritizable
  extend ActiveSupport::Concern

  included do
    before_action :prioritize_json_format
  end

  # rubocop:disable Metrics/PerceivedComplexity
  def prioritize_json_format
    if request.accepts.any?
      # Parse accept header directly since Mime::Type doesn't expose parameters
      accepts = request.headers['Accept'].to_s.split(',').map do |accept|
        type, params = accept.strip.split(';')
        # rubocop:disable Lint/NumberConversion
        q = params&.match(/q=([0-9.]+)/)&.[](1)&.to_f || 1.0
        # rubocop:enable Lint/NumberConversion
        [type, q]
      end.sort_by { |_, q| -q } # Sort by q value descending

      # If application/json has highest priority (tied or better),
      # force request format to JSON
      json_priority = accepts.find { |type, _| type == 'application/json' }&.last || 0
      highest_priority = accepts.first&.last || 0

      if json_priority >= highest_priority && json_priority > 0
        request.format = :json
      end
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity
end
