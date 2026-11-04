module Features::NetworkHelpers
  private

  def wait_for_network_idle
    expect(
      page.driver.browser.network.wait_for_idle(timeout: RSpec.configuration.wait_timeout),
    ).to eq(true)
  end
end
