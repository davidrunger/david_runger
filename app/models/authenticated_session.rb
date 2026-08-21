# == Schema Information
#
# Table name: authenticated_sessions
#
#  authenticatable_id                    :bigint           not null
#  authenticatable_type                  :string           not null
#  authentication_kind                   :string           not null
#  created_at                            :datetime         not null
#  id                                    :bigint           not null, primary key
#  identifier                            :string           not null
#  initial_ip                            :string           not null
#  initial_user_agent                    :text             not null
#  initiated_by_authenticated_session_id :bigint
#  isp                                   :string
#  last_active_at                        :datetime         not null
#  latest_ip                             :string           not null
#  latest_user_agent                     :text             not null
#  location                              :string
#  revoked_at                            :datetime
#  updated_at                            :datetime         not null
#
# Indexes
#
#  idx_on_initiated_by_authenticated_session_id_b250d18242  (initiated_by_authenticated_session_id)
#  index_authenticated_sessions_for_account_listing         (authenticatable_type,authenticatable_id,revoked_at)
#  index_authenticated_sessions_on_identifier               (identifier) UNIQUE
#
class AuthenticatedSession < ApplicationRecord
  AUTHENTICATION_KINDS = %w[admin_impersonation google_oauth legacy].freeze

  belongs_to :authenticatable, polymorphic: true
  belongs_to(
    :initiated_by_authenticated_session,
    class_name: 'AuthenticatedSession',
    optional: true,
    inverse_of: :initiated_authenticated_sessions,
  )
  has_many(
    :initiated_authenticated_sessions,
    class_name: 'AuthenticatedSession',
    dependent: :destroy,
    foreign_key: :initiated_by_authenticated_session_id,
    inverse_of: :initiated_by_authenticated_session,
  )

  has_paper_trail on: [:destroy]

  has_secure_token :identifier

  scope :active, -> { where(revoked_at: nil) }
  scope :visible_to_user, -> { where.not(authentication_kind: 'admin_impersonation') }

  validates :identifier, presence: true, uniqueness: true
  validates :authentication_kind, inclusion: { in: AUTHENTICATION_KINDS }
  validates :initiated_by_authenticated_session_id,
    presence: true,
    if: -> { authentication_kind == 'admin_impersonation' }
  validates :initial_ip,
    :latest_ip,
    :initial_user_agent,
    :latest_user_agent,
    :last_active_at,
    presence: true
  validate :valid_impersonation_parent

  def ip
    initial_ip
  end

  def active?
    revoked_at.nil?
  end

  def current_for?(rack_session, scope)
    identifier == rack_session[AuthenticatedSessions::Registry.session_key(scope)]
  end

  def belongs_to_authenticatable?(candidate)
    unless candidate
      return false
    end

    authenticatable_type == candidate.class.polymorphic_name && authenticatable_id == candidate.id
  end

  def record_activity!(request)
    current_minute = Time.current.change(sec: 0, usec: 0)
    if last_active_at >= current_minute
      return
    end

    self.class.
      where(id:).
      where(last_active_at: ...current_minute).
      # A conditional bulk update makes concurrent requests race-safe and intentionally skips
      # callbacks, including PaperTrail's update versioning.
      # rubocop:disable Rails/SkipsModelValidations
      update_all(
        last_active_at: current_minute,
        latest_ip: request.remote_ip,
        latest_user_agent: request.user_agent.to_s,
        updated_at: Time.current,
      )
    # rubocop:enable Rails/SkipsModelValidations
  end

  def revoke!
    newly_revoked = false
    transaction do
      if active?
        update!(revoked_at: Time.current)
        newly_revoked = true
      end
      initiated_authenticated_sessions.active.find_each(&:revoke!)
    end
    if newly_revoked
      disconnect_action_cable!
    end
  end

  private

  def disconnect_action_cable!
    unless authenticatable_type == 'User'
      return
    end

    ActionCable.server.remote_connections.
      where(
        authenticated_session_identifier: identifier,
        current_user: authenticatable,
      ).
      disconnect
  end

  def valid_impersonation_parent
    if authentication_kind == 'admin_impersonation'
      unless authenticatable_type == 'User'
        errors.add(:authenticatable, 'must be a User for impersonation')
      end
      if initiated_by_authenticated_session.present? &&
          initiated_by_authenticated_session.authenticatable_type != 'AdminUser'
        errors.add(:initiated_by_authenticated_session, 'must belong to an AdminUser')
      end
      if initiated_by_authenticated_session&.authentication_kind == 'admin_impersonation'
        errors.add(:initiated_by_authenticated_session, 'cannot be an impersonation')
      end
    elsif initiated_by_authenticated_session.present?
      errors.add(:initiated_by_authenticated_session, 'is only valid for impersonation')
    end
  end
end
