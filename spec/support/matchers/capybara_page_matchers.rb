RSpec::Matchers.define(:have_flash_message) do |expected_text, type:|
  match do |actual_page|
    expect(actual_page).to have_css(".flash__message--#{type}", text: expected_text)
  end

  match_when_negated do |actual_page|
    expect(actual_page).not_to have_css(".flash__message--#{type}", text: expected_text)
  end

  failure_message do |actual_page|
    <<~MESSAGE.squish
      expected page ('#{actual_page.text}') to have a(n) #{type} flash message
      with text '#{expected_text}'
    MESSAGE
  end

  failure_message_when_negated do |actual_page|
    <<~MESSAGE.squish
      expected page ('#{actual_page.text}') not to have a(n) #{type} flash
      message with text '#{expected_text}'
    MESSAGE
  end
end

RSpec::Matchers.define(:have_spinner) do
  match do |actual_page|
    expect(actual_page).to have_css('.spinner--circle')
  end

  match_when_negated do |actual_page|
    expect(actual_page).not_to have_css('.spinner--circle')
  end

  failure_message do |_actual_page|
    'expected page to have a spinner, but it did not'
  end

  failure_message_when_negated do |_actual_page|
    'expected page not to have a spinner, but it did'
  end
end
