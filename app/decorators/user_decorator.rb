class UserDecorator < Draper::Decorator
  delegate_all

  def partially_anonymized_username
    email_username, email_domain = email.split('@')

    if email_username.length >= 8
      partially_anonymized_email_username = "#{email_username[0..2]}...#{email_username[-3..]}"
      [partially_anonymized_email_username, email_domain].join('@')
    else
      "User #{id}"
    end
  end
end
