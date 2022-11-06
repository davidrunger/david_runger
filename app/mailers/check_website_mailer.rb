# frozen_string_literal: true

class CheckWebsiteMailer < ApplicationMailer
  def item_available(available_for_cash_carry, available_for_click_collect, quantity)
    @available_for_cash_carry = available_for_cash_carry
    @available_for_click_collect = available_for_click_collect
    @quantity = quantity

    mail(
      to: User.find(30).email,
      subject: 'The item you are waiting for is available',
    )
  end
end
