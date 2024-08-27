module Bootstrappable
  extend ActiveSupport::Concern

  included do
    helper_method :bootstrap
  end

  private

  def bootstrap(data = {})
    if data.present?
      # Adding a `nonce` ensures that the bootstrap data is always unique, which
      # is useful because that ensures that turbo will always evaluate the
      # `<script>` tag(s) within which it's wrapped.
      @bootstrap_data ||= {
        nonce: SecureRandom.uuid,
        current_user: current_user && UserSerializer::Basic.new(current_user),
      }

      @bootstrap_data.merge!(data)
    end

    @bootstrap_data
  end
end
