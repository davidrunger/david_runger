# frozen_string_literal: true

# https://github.com/rails/rails/issues/ 40855#issuecomment-1938103779
ActiveSupport.on_load(:action_controller) do
  if Rails.application.config.active_storage.service == :local
    include ActiveStorage::SetCurrent
  end
end
