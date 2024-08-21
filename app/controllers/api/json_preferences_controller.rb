class Api::JsonPreferencesController < ApplicationController
  def update
    @preference =
      current_user.
        json_preferences.
        find_or_initialize_by(
          preference_type: params[:preference_type].presence!,
        )

    authorize(@preference)

    if @preference.update(json: params[:json])
      render json: @preference.json
    else
      head :unprocessable_entity
    end
  end
end
