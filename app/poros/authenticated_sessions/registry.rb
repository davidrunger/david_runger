module AuthenticatedSessions::Registry
  SCOPES = { admin_user: AdminUser, user: User }.freeze

  class << self
    def session_key(scope)
      "authenticated_session_identifier.#{scope}"
    end

    def enforce!(authenticatable, warden, options)
      scope = options.fetch(:scope).to_sym
      scope_class = scope_class_for!(scope)
      unless authenticatable.is_a?(scope_class)
        raise(
          ArgumentError,
          "Expected #{scope_class} for Warden scope #{scope.inspect}, " \
          "got #{authenticatable.class}",
        )
      end

      rack_session = warden.request.session
      request = ActionDispatch::Request.new(warden.request.env)
      identifier_present = rack_session[session_key(scope)].present?
      identified_session = find_identified_session(rack_session, scope)
      is_fresh_authentication = options[:event] != :fetch

      if is_fresh_authentication
        identified_session&.revoke!
        authenticated_session = create_for_authentication!(
          authenticatable,
          warden,
          scope,
          request,
        )
        rack_session[session_key(scope)] = authenticated_session.identifier
      elsif identifier_present
        unless identified_session
          reject!(warden, rack_session, scope)
          return
        end
        unless valid_for?(
          identified_session,
          authenticatable,
          warden,
        )
          reject!(
            warden,
            rack_session,
            scope,
          )
          return
        end
        identified_session.record_activity!(request)
      else
        authenticated_session = enroll_legacy!(authenticatable, warden, scope, request)
        rack_session[session_key(scope)] = authenticated_session.identifier
      end
    end

    def revoke_for_logout(authenticatable, warden, options)
      scope = options.fetch(:scope).to_sym
      scope_class = scope_class_for!(scope)
      return unless authenticatable
      unless authenticatable.is_a?(scope_class)
        raise(
          ArgumentError,
          "Expected #{scope_class} for Warden scope #{scope.inspect}, " \
          "got #{authenticatable.class}",
        )
      end

      rack_session = warden.request.session
      find_identified_session(rack_session, scope)&.revoke!
      rack_session.delete(session_key(scope))
    end

    def create_impersonation!(user:, warden:)
      rack_session = warden.request.session
      parent = find_identified_session(rack_session, :admin_user)
      valid_parent = parent&.active? && parent.authenticatable == warden.user(:admin_user)
      raise(ActiveRecord::RecordNotFound) unless valid_parent

      find_identified_session(rack_session, :user)&.revoke!
      request = ActionDispatch::Request.new(warden.request.env)
      create_session!(
        authenticatable: user,
        authentication_kind: 'admin_impersonation',
        request:,
        initiated_by_authenticated_session: parent,
      )
    end

    def current(rack_session, scope)
      find_identified_session(rack_session, scope)&.then { |record| record if record.active? }
    end

    private

    def scope_class_for!(scope)
      SCOPES.fetch(scope) do
        raise(ArgumentError, "Unsupported Warden scope: #{scope.inspect}")
      end
    end

    def create_for_authentication!(authenticatable, warden, scope, request)
      authentication_kind = warden.request.env.delete(
        "authenticated_session.authentication_kind.#{scope}",
      )
      if (impersonation = warden.request.env.delete("authenticated_session.impersonation.#{scope}"))
        return impersonation
      end

      unless authentication_kind
        raise(
          ArgumentError,
          'No authentication kind registered for fresh Warden authentication ' \
          "in scope #{scope.inspect}",
        )
      end

      create_session!(
        authenticatable:,
        authentication_kind:,
        request:,
      )
    end

    def create_session!(
      authenticatable:,
      authentication_kind:,
      request:,
      initiated_by_authenticated_session: nil
    )
      current_minute = Time.current.change(sec: 0, usec: 0)
      authenticatable.authenticated_sessions.create!(
        authentication_kind:,
        initial_ip: request.remote_ip,
        latest_ip: request.remote_ip,
        initial_user_agent: request.user_agent.to_s,
        latest_user_agent: request.user_agent.to_s,
        last_active_at: current_minute,
        initiated_by_authenticated_session:,
      )
    end

    def enroll_legacy!(authenticatable, warden, scope, request)
      parent = legacy_impersonation_parent(authenticatable, warden, scope, request)
      create_session!(
        authenticatable:,
        authentication_kind: parent ? 'admin_impersonation' : 'legacy',
        request:,
        initiated_by_authenticated_session: parent,
      )
    end

    def legacy_impersonation_parent(authenticatable, warden, scope, request)
      return unless scope == :user

      admin_user = warden.user(:admin_user)
      # Matching emails are ambiguous here: the cookies may represent ordinary simultaneous
      # sign-ins rather than legacy Become. The explicit Become flow does not use this heuristic.
      return unless admin_user && admin_user.email != authenticatable.email

      rack_session = warden.request.session
      find_identified_session(rack_session, :admin_user) ||
        enroll_legacy!(admin_user, warden, :admin_user, request).tap do |parent|
          rack_session[session_key(:admin_user)] = parent.identifier
        end
    end

    def valid_for?(authenticated_session, authenticatable, warden)
      return false unless authenticated_session.active? &&
        authenticated_session.authenticatable == authenticatable
      return true unless authenticated_session.authentication_kind == 'admin_impersonation'

      parent = authenticated_session.initiated_by_authenticated_session
      rack_session = warden.request.session
      parent&.active? && parent.authenticatable == warden.user(:admin_user) &&
        parent.identifier == rack_session[session_key(:admin_user)]
    end

    def find_identified_session(rack_session, scope)
      identifier = rack_session[session_key(scope)]
      AuthenticatedSession.find_by(identifier:) if identifier.present?
    end

    def reject!(warden, rack_session, scope)
      rack_session.delete(session_key(scope))
      warden.logout(scope)
      # User and AdminUser authentication are independent. A revoked optional scope should not
      # abort a request that remains authenticated through the other scope.
      return if another_scope_authenticated?(warden, rack_session, scope)

      throw(:warden, scope:, action: :unauthenticated)
    end

    def another_scope_authenticated?(warden, rack_session, rejected_scope)
      SCOPES.keys.excluding(rejected_scope).any? do |scope|
        authenticatable = warden.user(scope:, run_callbacks: false)
        next false unless authenticatable

        identifier = rack_session[session_key(scope)]
        next true if identifier.blank?

        identified_session = find_identified_session(rack_session, scope)
        identified_session && valid_for?(identified_session, authenticatable, warden)
      end
    end
  end
end
