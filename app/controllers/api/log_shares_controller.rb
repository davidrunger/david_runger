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

      render_created_log_share(email_sent: delivery_limit.permitted?)
    else
      render_log_share_errors
    end
  end

  def destroy
    @log_share = current_user.log_shares.find_by(id: params[:id])
    if @log_share.nil?
      head(:not_found)
      skip_authorization
      return
    end

    authorize(@log_share)
    @log_share.destroy!
    head(:no_content)
  end

  private

  def log_share_params
    params.expect(log_share: %i[log_id email])
  end

  def render_log_share_errors
    render json: { errors: @log_share.errors.to_hash }, status: :unprocessable_content
  end

  def render_created_log_share(email_sent:)
    render_schema_json(
      @log_share.serializer(current_user:).as_json.merge(email_sent:),
      status: :created,
    )
  end
end
