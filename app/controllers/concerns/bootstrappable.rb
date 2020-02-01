# frozen_string_literal: true

module Bootstrappable
  extend ActiveSupport::Concern

  private

  def bootstrap(data)
    @bootstrap_data ||= {}
    @bootstrap_data.merge!(data)
  end
end
