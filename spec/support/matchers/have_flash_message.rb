RSpec::Matchers.define(:have_flash_message) do |expected_text, type:|
  match do |actual_page|
    expect(actual_page).to have_css(".flash__message--#{type}", text: expected_text)
  end

  failure_message do |actual_page|
    <<~MESSAGE.squish
      expected page ('#{actual_page.text}') to have a(n) #{type} flash message
      with text '#{expected_text}'
    MESSAGE
  end
end
