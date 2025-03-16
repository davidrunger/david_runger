class MyAccountController < ApplicationController
  self.container_classes = %w[p-8]

  def destroy
    @user =
      User.includes(
        :auth_tokens,
        :need_satisfaction_ratings,
        logs: [:log_shares, { log_entries: :log_entry_datum }],
        marriage: {
          check_ins: %i[check_in_submissions need_satisfaction_ratings],
          emotional_needs: :need_satisfaction_ratings,
        },
        quiz_participations: %i[quiz_question_answer_selections],
        quizzes: {
          participations: :quiz_question_answer_selections,
          questions: { answers: :selections },
        },
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
