# frozen_string_literal: true

module DataLogable
  extend ActiveSupport::Concern

  included do
    has_one :log_entry, as: :data_logable, dependent: :destroy
  end
end
