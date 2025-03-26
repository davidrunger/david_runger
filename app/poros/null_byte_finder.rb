class NullByteFinder
  def initialize(object)
    @object = object
  end

  def has_null_byte?
    case @object
    when String
      @object.include?("\u0000")
    when Array
      @object.any? { NullByteFinder.new(it).has_null_byte? }
    when Hash
      @object.keys.any? { NullByteFinder.new(it).has_null_byte? } ||
        @object.values.any? { NullByteFinder.new(it).has_null_byte? }
    else
      false
    end
  end
end
