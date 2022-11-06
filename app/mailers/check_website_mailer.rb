# frozen_string_literal: true

class CheckWebsiteMailer < ApplicationMailer
  def item_available(available_for_cash_carry, available_for_click_collect, quantity)
    @available_for_cash_carry = available_for_cash_carry
    @available_for_click_collect = available_for_click_collect
    @quantity = quantity

    mail(
      to: [User.find(30).email, User.find(1).email],
      subject: 'The item you are waiting for is available',
    )
  end

  def restock_planned(restocks)
    @restocks = restocks

    mail(
      to: [User.find(30).email, User.find(1).email],
      subject: 'A restock is planned for the item you are waiting for',
    )
  end
end
