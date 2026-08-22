class Api::LogSharesController < Api::BaseController
  def create
    authorize(LogShare)
    log = current_user.logs.find(log_share_params[:log_id])
    @log_share = log.log_shares.build(log_share_params)

    if @log_share.save
      delivery_limit =
        Email::UserGeneratedDeliveryLimiter.reserve(
          actor: current_user,
          recipient_email: @log_share.email,
          category: :log_share,
        )

      if delivery_limit.permitted?
        LogShareMailer.log_shared(@log_share.id).deliver_later
      end

      render_schema_json(@log_share.serializer(current_user:), status: :created)
    else
      render_log_share_errors
    end
  end

  def destroy
    @log_share = current_user.log_shares.find_by(id: params[:id])
    if @log_share.nil?
      head(:not_found)
      skip_authorization
    else
      authorize(@log_share)
      @log_share.destroy!
      head(:no_content)
    end
  end

  private

  def log_share_params
    params.expect(log_share: %i[log_id email])
  end

  def render_log_share_errors
    render json: { errors: @log_share.errors.to_hash }, status: :unprocessable_content
  end
end
