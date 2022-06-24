# frozen_string_literal: true

# disable prerendering for review apps because needed ENV['HEROKU_SLUG_COMMIT'] is not present
puts('Disabling prerendering')
Flipper.enable(:disable_prerendering)

puts('Enabling automatic login')
Flipper.enable(:automatic_user_login)
Flipper.enable(:automatic_admin_login)
