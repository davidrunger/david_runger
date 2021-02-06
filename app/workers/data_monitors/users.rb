# frozen_string_literal: true

class DataMonitors::Users < DataMonitors::Base
  prepend ApplicationWorker

  def perform
    verify_data_expectation(
      check_name: :admin_email_addresses,
      expectation: %w[davidjrunger@gmail.com],
    )

    verify_data_expectation(
      check_name: :user_count,
      expectation: (4..100),
    )
  end

  private

  def admin_email_addresses
    User.admin.pluck(:email)
  end

  def user_count
    User.count
  end
end
