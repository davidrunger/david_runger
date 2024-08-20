class EmojiPickerController < ApplicationController
  skip_before_action :authenticate_user!
  self.container_classes = %w[p-8]

  def index
    skip_authorization

    @title = 'Emoji Picker'
    @description = <<~DESCRIPTION.squish
      A fast and simple emoji selector with an auto-focused search field and
      keyboard selection.
    DESCRIPTION

    render :index
  end
end
