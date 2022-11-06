# frozen_string_literal: true

class CheckWebsite
  extend Memoist
  include Throttleable
  prepend ApplicationWorker

  TIME_BETWEEN_EMAIL_ALERTS = 1.day.freeze

  def perform
    available_for_cash_carry = nil
    available_for_click_collect = nil
    quantity = nil

    availabilities.find do |availability|
      case availability.deep_symbolize_keys
      in {
        availableForCashCarry: available_for_cash_carry,
        availableForClickCollect: available_for_click_collect,
        buyingOption: { cashCarry: { availability: { quantity: } } },
        classUnitKey: { classUnitCode: '410' },
      } then true
      else false
      end
    end

    Rails.logger.info(<<~LOG.squish)
      [#{self.class.name}]
      available_for_cash_carry=#{available_for_cash_carry}
      available_for_click_collect=#{available_for_click_collect}
      quantity=#{quantity}
    LOG

    if available_for_cash_carry || available_for_click_collect || (quantity > 0)
      lock_key = "#{self.class.name}:email-alert"
      throttled('send email', lock_key, TIME_BETWEEN_EMAIL_ALERTS) do
        CheckWebsiteMailer.item_available(
          available_for_cash_carry,
          available_for_click_collect,
          quantity,
        ).deliver_later
      end
    end
  end

  private

  memoize \
  def availabilities
    Faraday. # rubocop:disable Style/SingleArgumentDig
      json_connection.
      get(
        ENV.fetch('CHECK_WEBSITE_URL'),
        nil,
        {
          'Accept' => 'application/json;version=2',
          'Accept-Language' => 'en-US,en;q=0.5',
          'X-Client-ID' => ENV.fetch('X_CLIENT_ID'),
        },
      ).
      body.
      dig('availabilities')
  end
end
