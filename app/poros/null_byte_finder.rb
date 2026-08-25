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
      NullByteFinder.new(@object.keys).has_null_byte? ||
        NullByteFinder.new(@object.values).has_null_byte?
    else
      false
    end
  end
end
