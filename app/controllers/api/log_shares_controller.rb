# frozen_string_literal: true

class Api::LogSharesController < ApplicationController
  def create
    log = current_user.logs.find(log_share_params[:log_id])
    @log_share = log.log_shares.build(log_share_params)

    if @log_share.save
      render json: @log_share, status: :created
    else
      render json: {errors: @log_share.errors.to_hash}, status: :unprocessable_entity
    end
  end

  def destroy
    @log_share = current_user.log_shares.find_by(id: params[:id])
    head(404) && return if @log_share.nil?

    @log_share.destroy!
    head(204)
  end

  private

  def log_share_params
    params.require(:log_share).permit(:log_id, :email)
  end
end
