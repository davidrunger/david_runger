# Inspired by https://www.marcelofossrj.com/recipe/2019/04/14/custom-errors.html
class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :skip_authorization

  def not_found
    if (exception = request.env['action_dispatch.exception'])
      Rails.error.report(
        exception,
        context: {
          path: request.env['REQUEST_URI'],
          request: request.env.dig('rollbar.scope', :request)&.call,
        },
      )
    end

    respond_to do |format|
      format.html { render file: 'public/404.html', status: :not_found, layout: false }
      format.json { render json: { error: 'Not Found' }, status: :not_found }
      format.any { render plain: 'Not found' }
    end
  end

  def unacceptable
    respond_to do |format|
      format.html { render file: 'public/422.html', status: :unprocessable_entity, layout: false }
      format.json { render json: { error: 'Params unacceptable' }, status: :unprocessable_entity }
      format.any { render plain: 'Params unacceptable' }
    end
  end

  def internal_error
    respond_to do |format|
      format.html { render status: :internal_server_error, layout: false }
      format.json do
        render json: { error: 'Internal server error' }, status: :internal_server_error
      end
      format.any { render plain: 'Internal server error' }
    end
  end
end
