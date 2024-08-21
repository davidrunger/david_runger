class Api::JsonPreferencesController < ApplicationController
  def update
    @preference =
      current_user.
        json_preferences.
        find_or_initialize_by(
          preference_type: params[:preference_type].presence!,
        )

    authorize(@preference)

    @preference.update!(json: params[:json])
  end
end
