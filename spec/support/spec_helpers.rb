# frozen_string_literal: true

module SpecHelpers
  def json_response
    JSON(response.body)
  end

  def activate_feature!(feature_name)
    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(feature_name).and_return(true)
  end
end
