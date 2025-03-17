module JsToastable
  extend ActiveSupport::Concern

  included do
    helper_method :render_flash_messages_via_js?
  end

  class_methods do
    attr_reader :actions_for_which_to_render_flash_messages_via_js

    def render_flash_messages_via_js(only:)
      @actions_for_which_to_render_flash_messages_via_js = only.map(&:to_sym)
    end
  end

  def render_flash_messages_via_js?
    if (js_flash_actions = self.class.actions_for_which_to_render_flash_messages_via_js)
      params[:action].to_sym.in?(js_flash_actions)
    else
      false
    end
  end
end
