module SpecHelpers
  def json_response
    JSON(response.body)
  end

  def activate_feature!(feature_name)
    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(feature_name).and_return(true)
  end

  def wait_until
    Prosopite.pause do
      50.times do
        if yield
          return
        else
          sleep(0.1)
        end
      end
    end
  end
end
