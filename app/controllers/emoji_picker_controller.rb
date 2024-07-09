# frozen_string_literal: true

class EmojiPickerController < ApplicationController
  skip_before_action :authenticate_user!
  self.container_classes = %w[p-8]

  def index
    skip_authorization
    @title = 'Emoji Picker'
    render :index
  end
end
