class Logs::LogFormatter < Lograge::Formatters::KeyValue
  def initialize(data)
    controller = data.delete(:controller) # e.g. 'Api::LogEntriesController'
    action = data[:action] # e.g. 'index'

    # convert to 'api/log_entries#index'
    if controller && action
      data[:action] = "#{controller.delete_suffix('Controller').underscore}##{action}"
    end

    @data =
      data.
        sort_by.
        with_index do |(key, _value), index|
          case key
          when :action then 0
          when :path then 1
          when :method then 2
          when :format then 3
          when :params then 4
          when :status then 5
          when :queries then 5.3
          when :cached_queries then 5.6
          when :allocations then 6
          when :duration then 7
          when :db then 8
          when :view then 9
          when :ip then 10
          when :admin_user_id then 11
          when :user_id then 12
          else index + 13
          end
        end.to_h
  end

  # rubocop:disable Metrics/PerceivedComplexity
  def call
    fields_to_display(@data).
      map do |key|
        value = @data[key]
        key_value_string = format(key, value)

        if Rails.env.development? || (Rails.env.test? && !Rainbow.enabled)
          color, background, style = color_background_and_style(key, value)

          if defined?(Rainbow) # Rainbow won't be defined when running w/ Docker
            key_value_string =
              Rainbow(key_value_string).
                color(color).
                background(background || :default).
                public_send(style || :itself)
          end
        end

        key_value_string
      end.
      join(' ').
      tap do |log_line|
        if Rails.env.development?
          log_line << "\n\n"
        end
      end
  end
  # rubocop:enable Metrics/PerceivedComplexity

  private

  # rubocop:disable Lint/DuplicateBranch
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  def color_background_and_style(key, value)
    case key.to_sym
    when :action
      %i[black blue]
    when :path
      :magenta
    when :method
      %i[magenta default underline]
    when :format
      :magenta
    when :params
      :cyan
    when :status
      case value / 100
      when 2 then :green
      when 3 then :yellow
      else %i[black red]
      end
    when :queries
      if value < 5
        :green
      elsif value < 12
        :yellow
      else
        :red
      end
    when :cached_queries
      :white
    when :allocations
      if value < 20_000
        :green
      elsif value < 80_000
        :yellow
      else
        :red
      end
    when :duration, :view, :db
      if value < 100
        :green
      elsif value < 500
        :yellow
      else
        :red
      end
    when :ip
      :white
    when :admin_user_id
      :blue
    when :user_id
      :cyan
    else
      :default
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Lint/DuplicateBranch
end
