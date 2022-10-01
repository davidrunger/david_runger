# frozen_string_literal: true

require 'memoist'

class Clock::Schedule
  extend Memoist

  def initialize(schedule_string)
    @hour, @minute = schedule_string.split(':')
  end

  def matches?(time)
    hour_match?(time) && minute_match?(time)
  end

  private

  def hour_match?(time)
    @hour == '**' || time.hour == integer_hour
  end

  def minute_match?(time)
    @minute == '**' || time.min == integer_minute
  end

  memoize \
  def integer_hour
    Integer(@hour.delete_prefix('0'))
  end

  memoize \
  def integer_minute
    Integer(@minute.delete_prefix('0'))
  end
end
