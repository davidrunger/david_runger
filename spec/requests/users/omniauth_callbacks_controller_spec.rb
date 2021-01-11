# frozen_string_literal: true

RSpec.describe Users::OmniauthCallbacksController do
  # Make sure that https://nvd.nist.gov/vuln/detail/CVE-2015-9284 is mitigated.
  # Specs borrowed with modification from
  # https://github.com/omniauth/omniauth/pull/809#issuecomment-512689882
  describe 'mitigating CVE-2015-9284' do
    describe 'GET /auth/:provider' do
      specify do
        expect { get('/auth/google_oauth2') }.
          to raise_error(ActionController::RoutingError)
      end
    end

    describe 'POST /auth/:provider without CSRF token' do
      around do |spec|
        original_allow_forgery_protection = ActionController::Base.allow_forgery_protection
        ActionController::Base.allow_forgery_protection = true

        spec.run

        ActionController::Base.allow_forgery_protection = original_allow_forgery_protection
      end

      it 'redirects to `/auth/failure?[...]`' do
        post('/auth/google_oauth2')
        expect(response).to redirect_to(
          '/auth/failure' \
          '?message=ActionController%3A%3AInvalidAuthenticityToken' \
          '&strategy=google_oauth2',
        )
      end
    end
  end
end
