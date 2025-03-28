RSpec::Matchers.define(:have_flash_message) do |expected_text, type: :notice|
  class_for_type = ".flash__message.flash__message--#{type}"

  match do |actual_page|
    expect(actual_page).to have_css(class_for_type, text: expected_text)
  end

  match_when_negated do |actual_page|
    expect(actual_page).not_to have_css(class_for_type, text: expected_text)
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

RSpec::Matchers.define(:have_toastify_toast) do |expected_text, type: :default|
  extend ActionView::Helpers::TagHelper

  class_list_for_type = class_names(
    'toastify',
    case type
    in :error then 'error'
    else nil
    end,
  )

  class_selector = ".#{class_list_for_type.tr(' ', '.')}"

  match do |actual_page|
    expect(actual_page).to have_css(class_selector, text: expected_text)
  end

  match_when_negated do |actual_page|
    expect(actual_page).not_to have_css(class_selector, text: expected_text)
  end

  failure_message do |actual_page|
    <<~MESSAGE.squish
      expected page ('#{actual_page.text}') to have a Toastify toast of type #{type}
      with text '#{expected_text}'
    MESSAGE
  end

  failure_message_when_negated do |actual_page|
    <<~MESSAGE.squish
      expected page ('#{actual_page.text}') not to have a Toastify toast of type #{type}
      with text '#{expected_text}'
    MESSAGE
  end
end

RSpec::Matchers.define(:have_vue_toast) do |expected_text, type: :default|
  extend ActionView::Helpers::TagHelper

  class_list_for_type = class_names(
    'Vue-Toastification__toast',
    case type
    in :error then 'Vue-Toastification__toast--error'
    else 'Vue-Toastification__toast--default'
    end,
  )

  class_selector = ".#{class_list_for_type.tr(' ', '.')} .Vue-Toastification__toast-body"

  match do |actual_page|
    expect(actual_page).to have_css(class_selector, text: expected_text)
  end

  match_when_negated do |actual_page|
    expect(actual_page).not_to have_css(class_selector, text: expected_text)
  end

  failure_message do |actual_page|
    <<~MESSAGE.squish
      expected page ('#{actual_page.text}') to have a Vue toast of type #{type}
      with text '#{expected_text}'
    MESSAGE
  end

  failure_message_when_negated do |actual_page|
    <<~MESSAGE.squish
      expected page ('#{actual_page.text}') not to have a Vue toast of type #{type}
      with text '#{expected_text}'
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
