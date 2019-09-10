# frozen_string_literal: true

RSpec.describe Users::OmniauthCallbacksController do
  # Make sure that https://nvd.nist.gov/vuln/detail/CVE-2015-9284 is mitigated.
  # Specs borrowed with modification from
  # https://github.com/omniauth/omniauth/pull/809#issuecomment-512689882
  describe 'mitigating CVE-2015-9284' do
    describe 'GET /users/auth/:provider' do
      specify do
        get(user_google_oauth2_omniauth_authorize_path)
        expect(response).to redirect_to(login_path)
      end
    end

    describe 'POST /users/auth/:provider without CSRF token' do
      before do
        @original_allow_forgery_protection = ActionController::Base.allow_forgery_protection
        ActionController::Base.allow_forgery_protection = true
      end

      after do
        ActionController::Base.allow_forgery_protection = @original_allow_forgery_protection
      end

      specify do
        expect { post(user_google_oauth2_omniauth_authorize_path) }.
          to raise_error(ActionController::InvalidAuthenticityToken)
      end
    end
  end
end
