# frozen_string_literal: true

class PublicFilesController < ApplicationController
  self.container_classes = %w[py-2 px-8]

  skip_before_action :authenticate_user!, only: %i[create index new]
  before_action :authenticate_admin_user!

  def create
    authorize(:public_file)
    current_admin_user.public_files.attach(params[:public_file])
    flash[:notice] = 'Public file uploaded successfully!'
    redirect_to(public_files_path)
  end

  def index
    authorize(:public_file)
    @public_files = policy_scope(:public_file).includes(:blob)
  end

  def new
    authorize(:public_file)
  end

  private

  def pundit_user
    current_admin_user
  end
end
