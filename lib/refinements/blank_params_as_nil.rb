module BlankParamsAsNil
  refine ActionController::Parameters do
    def blank_params_as_nil(params)
      params.each do |param|
        value = self[param]
        if value && value.blank?
          self[param] = nil
        end
      end

      self
    end
  end
end
