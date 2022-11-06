# frozen_string_literal: true

class CheckWebsite
  extend Memoist
  include Throttleable
  prepend ApplicationWorker

  TIME_BETWEEN_EMAIL_ALERTS = 1.day.freeze

  # rubocop:disable Metrics/MethodLength
  def perform
    available_for_cash_carry = nil
    available_for_click_collect = nil
    availability_detail = nil

    availabilities.find do |availability|
      case availability.deep_symbolize_keys
      in {
        classUnitKey: { classUnitCode: '410' },
        availableForCashCarry: available_for_cash_carry,
        availableForClickCollect: available_for_click_collect,
        buyingOption: { cashCarry: { availability: availability_detail } },
      } then true
      else false
      end
    end

    quantity, restocks = availability_detail.values_at(:quantity, :restocks)

    Rails.logger.info(<<~LOG.squish)
      [#{self.class.name}]
      available_for_cash_carry=#{available_for_cash_carry}
      available_for_click_collect=#{available_for_click_collect}
      quantity=#{quantity}
      restocks=#{restocks}
    LOG

    if available_for_cash_carry || available_for_click_collect || (quantity > 0)
      lock_key = "#{self.class.name}:item_available:email-alert"
      throttled('send item_available email', lock_key, TIME_BETWEEN_EMAIL_ALERTS) do
        CheckWebsiteMailer.item_available(
          available_for_cash_carry,
          available_for_click_collect,
          quantity,
        ).deliver_later
      end
    elsif restocks.present?
      lock_key = "#{self.class.name}:restock_planned:email-alert"
      throttled('send restock_planned email', lock_key, TIME_BETWEEN_EMAIL_ALERTS) do
        CheckWebsiteMailer.restock_planned(restocks).deliver_later
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  private

  memoize \
  def availabilities
    json['availabilities']
  end

  memoize \
  def json
    Faraday.
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
      body
  end
end
