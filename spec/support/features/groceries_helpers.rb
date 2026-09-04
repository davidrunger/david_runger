module Features::GroceriesHelpers
  private

  def click_item_action(item, action)
    open_item_actions(item)

    find(
      '[role="menuitem"]',
      text: action,
      exact_text: true,
    ).click
  end

  def click_store_setting(store, setting)
    open_store_settings(store)

    find(
      '[role="menuitem"]',
      text: setting,
      exact_text: true,
    ).click
  end

  def open_item_actions(item)
    within("#grocery-item-#{item.id}") do
      find_button("Actions for #{item.name}").click
    end
  end

  def open_store_settings(store)
    find_button("Settings for #{store.name}").click
  end

  def expect_needed(item_name, needed)
    item = find('.grocery-item', text: item_name)

    if needed > 0
      expect(item).to have_text("#{item_name} (#{needed})")
    else
      expect(item).not_to have_text('(0)')
    end
  end
end
