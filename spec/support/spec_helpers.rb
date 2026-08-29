module SpecHelpers
  def activate_feature!(feature_name)
    @activated_features ||= []
    if @activated_features.exclude?(feature_name)
      @activated_features << feature_name
    end

    allow(Flipper).to receive(:enabled?).and_call_original
    @activated_features.each do |activated_feature|
      allow(Flipper).to receive(:enabled?).with(activated_feature).and_return(true)
    end
  end
end
