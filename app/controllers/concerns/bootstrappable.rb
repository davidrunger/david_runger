module Bootstrappable
  extend ActiveSupport::Concern

  included do
    helper_method :bootstrap
  end

  private

  def bootstrap(data = {})
    # Adding a `nonce` ensures that the bootstrap data is always unique, which
    # is useful because that ensures that turbo will always evaluate the
    # `<script>` tag(s) within which it's wrapped.
    @bootstrap_data ||=
      begin
        notice_flash_messages = flash[:toast_messages] || []

        if render_flash_messages_via_js?
          notice_flash_messages.concat(Array(flash[:notice]))

          alert_flash_messages = Array(flash[:alert])
        end

        {
          current_user: current_user && UserSerializer::Basic.new(current_user),
          nonce: SecureRandom.uuid,
          alert_toast_messages: alert_flash_messages || [],
          notice_toast_messages: notice_flash_messages,
        }.compact_blank!
      end

    if data.present?
      @bootstrap_data.merge!(data)
    end

    @bootstrap_data
  end
end
