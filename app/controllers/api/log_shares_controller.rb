# frozen_string_literal: true

class Api::LogSharesController < ApplicationController
  def create
    authorize(LogShare)
    log = current_user.logs.find(log_share_params[:log_id])
    @log_share = log.log_shares.build(log_share_params)

    if @log_share.save
      LogShareMailer.log_shared(@log_share.id).deliver_later
      render json: @log_share, status: :created
    else
      render json: { errors: @log_share.errors.to_hash }, status: :unprocessable_entity
    end
  end

  def destroy
    @log_share = current_user.log_shares.find_by(id: params[:id])
    if @log_share.nil?
      head(404)
      skip_authorization
      return
    end

    authorize(@log_share)
    @log_share.destroy!
    head(204)
  end

  private

  def log_share_params
    params.require(:log_share).permit(:log_id, :email)
  end
end
