class UsersController < ApplicationController
  self.container_classes = %w[p-8]

  def destroy
    @user =
      User.includes(
        logs: %i[log_shares number_log_entries text_log_entries],
      ).find(params[:id])
    authorize(@user)

    @user.destroy!

    flash[:notice] = 'We have deleted your account.'
    redirect_to(root_path)
  end

  def edit
    @user = User.find(params[:id])
    authorize(@user)
    render :edit
  end
end
