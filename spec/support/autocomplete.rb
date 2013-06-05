
  def fill_autocomplete(item_text, input_selector="input[data-autocomplete]")
    page.execute_script %Q{ $('#{input_selector}').trigger("focus") }
    page.execute_script %Q{ $('#{input_selector}').trigger("keydown") }

    # Set up a selector, wait for it to appear on the page, then use it.
    item_selector = "ul.ui-autocomplete li.ui-menu-item a:contains('#{item_text}')"
    page.should have_selector item_selector
    page.execute_script %Q{ $("#{item_selector}").trigger("mouseenter").trigger("click"); }
  end

