class MyAccountController < ApplicationController
  self.container_classes = %w[p-8]

  def destroy
    @user =
      User.includes(
        logs: %i[log_entries log_shares],
        stores: :items,
      ).find(current_user.id)
    authorize(@user)

    @user.destroy!

    flash[:notice] = 'We have deleted your account.'
    redirect_to(root_path)
  end

  def edit
    @user = current_user
    authorize(@user)
    render :edit
  end

  def show
    @user = current_user
    authorize(@user)
    render :show
  end
end
