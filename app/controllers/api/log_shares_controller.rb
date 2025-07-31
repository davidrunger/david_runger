class Api::LogSharesController < Api::BaseController
  def create
    authorize(LogShare)
    log = current_user.logs.find(log_share_params[:log_id])
    @log_share = log.log_shares.build(log_share_params)

    if @log_share.save
      LogShareMailer.log_shared(@log_share.id).deliver_later
      render_schema_json(@log_share, status: :created)
    else
      render json: { errors: @log_share.errors.to_hash }, status: :unprocessable_content
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
end
