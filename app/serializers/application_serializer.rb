class ApplicationSerializer
  include Alba::Resource

  class << self
    attr_accessor :_filtered_attributes

    def filtered_attributes(*filtered_attributes)
      self._filtered_attributes = filtered_attributes
    end
  end

  def attributes
    if self.class._filtered_attributes
      super.select { |key, _value| key.in?(self.class._filtered_attributes) }
    else
      super
    end
  end

  private

  def current_user
    params[:current_user]
  end
end
