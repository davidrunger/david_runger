# Borrowed from capybara_accessible_selectors:
# https://github.com/citizensadvice/capybara_accessible_selectors/blob/v0.12.0/lib/capybara_accessible_selectors/selectors/section.rb

Capybara.add_selector(:section) do
  xpath do |locator, heading_level: (1..6), section_element: %i[
    section
    article
    aside
    form
    main
    header
    footer
  ], **|
    heading = [
      (XPath.attr(:role) == 'heading') &
        Array(heading_level).map { XPath.attr(:'aria-level') == it.to_s }.reduce(:|),
      if Array(heading_level).include?(2)
        (XPath.attr(:role) == 'heading') & !XPath.attr(:'aria-level')
      end,
      Array(heading_level).map { XPath.self(:"h#{it}") & !XPath.attr(:'aria-level') }.reduce(:|),
      Array(heading_level).map { XPath.attr(:'aria-level') == it.to_s }.
        reduce(:|) & %i[h1 h2 h3 h4 h5 h6].map { XPath.self(it) }.reduce(:|),
    ].compact.reduce(:|)

    has_heading = XPath.function(
      nil,
      XPath.descendant[[
        *[
          :section,
          :article,
          :aside,
          :form,
          :main,
          :header,
          :footer,
          *(1..6).map { :"h#{it}" },
        ].map { XPath.self(it) },
        XPath.attr(:role) == 'heading',
      ].reduce(:|)],
    )[1][heading]

    if locator
      has_heading = has_heading[XPath.string.n.is(locator.to_s)]
    end

    XPath.descendant(*Array(section_element).map(&:to_sym))[has_heading]
  end
end

module ::Capybara::DSL
  def within_section(...)
    within(:section, ...)
  end
end

module Capybara::RSpecMatchers
  def have_section(locator = nil, **options, &optional_filter_block)
    Matchers::HaveSelector.new(:section, locator, **options, &optional_filter_block)
  end
end
