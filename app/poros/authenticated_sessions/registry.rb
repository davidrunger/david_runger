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
        if identified_session && valid_for?(identified_session, authenticatable, warden)
          identified_session.record_activity!(request)
        else
          reject!(warden, rack_session, scope)
        end
      else
        authenticated_session = enroll_legacy!(authenticatable, warden, scope, request)
        rack_session[session_key(scope)] = authenticated_session.identifier
      end
    end

    def revoke_for_logout(authenticatable, warden, options)
      scope = options.fetch(:scope).to_sym
      scope_class = scope_class_for!(scope)
      if authenticatable
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
    end

    def create_impersonation!(user:, warden:)
      rack_session = warden.request.session
      parent = find_identified_session(rack_session, :admin_user)
      valid_parent = parent&.active? && parent.belongs_to_authenticatable?(warden.user(:admin_user))
      unless valid_parent
        raise(ActiveRecord::RecordNotFound)
      end

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
      find_identified_session(rack_session, scope)&.then do |record|
        if record.active?
          record
        end
      end
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
        impersonation
      else
        if !authentication_kind
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
    end

    def create_session!(
      authenticatable:,
      authentication_kind:,
      request:,
      initiated_by_authenticated_session: nil
    )
      AuthenticatedSessions::Create.run!(
        authenticatable:,
        authentication_kind:,
        request:,
        initiated_by_authenticated_session:,
      ).authenticated_session
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
      if scope == :user
        admin_user = warden.user(:admin_user)
        # Matching emails are ambiguous here: the cookies may represent ordinary simultaneous
        # sign-ins rather than legacy Become. The explicit Become flow does not use this heuristic.
        if admin_user && admin_user.email != authenticatable.email
          rack_session = warden.request.session
          find_identified_session(rack_session, :admin_user) ||
            enroll_legacy!(admin_user, warden, :admin_user, request).tap do |parent|
              rack_session[session_key(:admin_user)] = parent.identifier
            end
        end
      end
    end

    def valid_for?(authenticated_session, authenticatable, warden)
      if (
        !authenticated_session.active? ||
          !authenticated_session.belongs_to_authenticatable?(authenticatable)
      )
        false
      elsif authenticated_session.authentication_kind != 'admin_impersonation'
        true
      else
        parent = authenticated_session.initiated_by_authenticated_session
        rack_session = warden.request.session
        parent&.active? && parent.belongs_to_authenticatable?(warden.user(:admin_user)) &&
          parent.identifier == rack_session[session_key(:admin_user)]
      end
    end

    def find_identified_session(rack_session, scope)
      identifier = rack_session[session_key(scope)]
      if identifier.present?
        AuthenticatedSession.find_by(identifier:)
      end
    end

    def reject!(warden, rack_session, scope)
      rack_session.delete(session_key(scope))
      warden.logout(scope)
      # User and AdminUser authentication are independent. A revoked optional scope should not
      # abort a request that remains authenticated through the other scope.
      if !another_scope_authenticated?(warden, rack_session, scope)
        throw(:warden, scope:, action: :unauthenticated)
      end
    end

    def another_scope_authenticated?(warden, rack_session, rejected_scope)
      SCOPES.keys.excluding(rejected_scope).any? do |scope|
        authenticatable = warden.user(scope:, run_callbacks: false)
        unless authenticatable
          next false
        end

        identifier = rack_session[session_key(scope)]
        if identifier.blank?
          next true
        end

        identified_session = find_identified_session(rack_session, scope)
        identified_session && valid_for?(identified_session, authenticatable, warden)
      end
    end
  end
end
