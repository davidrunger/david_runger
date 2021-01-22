# frozen_string_literal: true

module HashidRequireable
  class HashidNotProvided < StandardError ; end

  extend ActiveSupport::Concern

  included do
    rescue_from HashidNotProvided, with: :render_404
  end

  private

  def require_hashid_param!(resource)
    # require use of `hashid` as `:id` param; don't allow use of raw integer id
    if params[:id] != resource.hashid
      raise(HashidNotProvided)
    end
  end

  def render_404
    render file: 'public/404.html', status: :not_found, layout: false
  end
end
