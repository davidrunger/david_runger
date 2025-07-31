class Api::JsonPreferencesController < Api::BaseController
  def update
    @preference =
      current_user.
        json_preferences.
        find_or_initialize_by(
          preference_type: params[:preference_type].presence!,
        )

    authorize(@preference)

    if @preference.update(json: params[:json])
      head :ok
    else
      head :unprocessable_content
    end
  end
end
