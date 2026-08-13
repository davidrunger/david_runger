class AuthenticatedSessionPolicy < ApplicationPolicy
  def revoke?
    record.authenticatable == user && record.authentication_kind != 'admin_impersonation'
  end
end
