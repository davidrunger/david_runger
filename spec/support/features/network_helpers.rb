module Features::NetworkHelpers
  private

  def wait_for_network_idle
    expect(
      page.driver.wait_for_network_idle(timeout: RSpec.configuration.wait_timeout),
    ).to eq(true)
  end
end
