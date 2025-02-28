class ApplicationSerializer
  include Alba::Resource
  include Typelizer::DSL

  class_attribute :decorator_class

  class << self
    def decorate_with(decorator)
      self.decorator_class = decorator
    end
  end

  private

  def current_user
    params[:current_user]
  end

  # NOTE: Here we are effectively monkeypatching alba.
  def attributes_to_hash(obj, hash)
    if (decorator_class = self.class.decorator_class)
      super(decorator_class.new(obj), hash)
    else
      super
    end
  end
end
