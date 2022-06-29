# frozen_string_literal: true

Item.find_each.
  select { |item| item.name.match?(/(\A\s+|\s+\z)/) }.
  each(&:save!) # whitespace will be stripped from item name by `auto_strip_attributes`
