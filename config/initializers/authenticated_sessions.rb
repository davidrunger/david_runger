Warden::Manager.after_set_user do |authenticatable, warden, options|
  AuthenticatedSessions::Registry.enforce!(authenticatable, warden, options)
end

Warden::Manager.before_logout do |authenticatable, warden, options|
  AuthenticatedSessions::Registry.revoke_for_logout(authenticatable, warden, options)
end
