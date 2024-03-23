# frozen_string_literal: true

class NullByteFinder
  def initialize(object)
    @object = object
  end

  def has_null_byte?
    if @object.blank?
      false
    elsif @object.is_a?(String)
      @object.include?("\u0000")
    elsif @object.is_a?(Array)
      @object.any? { NullByteFinder.new(_1).has_null_byte? }
    elsif @object.is_a?(Hash)
      @object.keys.any? { NullByteFinder.new(_1).has_null_byte? } ||
        @object.values.any? { NullByteFinder.new(_1).has_null_byte? }
    else
      fail "Do not know how to check for null bytes in object: #{@object.inspect}."
    end
  end
end
