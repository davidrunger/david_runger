module Redirectable
  extend ActiveSupport::Concern

  included do
    before_action :store_redirect_chain
  end

  def redirect_location
    next_redirect_chain_value ||
      session.delete('user_return_to') ||
      root_path
  end

  def store_redirect_chain
    if (
      redirect_chain =
        params[:redirect_chain] ||
        request.env['omniauth.origin'].presence
    ) && !redirect_chain.in?([new_user_session_url, new_admin_user_session_url])
      session[:redirect_chain] = redirect_chain
    end
  end

  def next_redirect_chain_value
    if (redirect_chain = session.delete(:redirect_chain)&.split('|'))
      next_value = first_redirect_chain_value_to_follow(redirect_chain)

      if redirect_chain.present?
        session[:redirect_chain] = redirect_chain.join('|')
      end

      next_value
    end
  end

  def first_redirect_chain_value_to_follow(redirect_chain)
    20.times do
      next_value = redirect_chain.shift

      if next_value.start_with?('wizard:')
        wizard_type = next_value.delete_prefix('wizard:')

        if wizard_type == 'set-public-name-if-new' && current_user.created_at > 1.minute.ago
          return edit_public_name_my_account_path
        end
      else
        return next_value
      end
    end

    nil
  end
end
