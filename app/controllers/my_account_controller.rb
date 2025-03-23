class MyAccountController < ApplicationController
  self.container_classes = %w[p-8]

  def destroy
    @user = User.with_eager_loading_for_destroy.find(current_user.id)

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

  def edit_public_name
    authorize(current_user, :edit?)
    render :edit_public_name
  end

  def show
    @user = current_user
    authorize(@user)
    render :show
  end

  def update
    authorize(current_user)
    current_user.update!(my_account_params)
    redirect_to(redirect_location)
  end

  private

  def my_account_params
    params.expect(user: %i[public_name])
  end
end
