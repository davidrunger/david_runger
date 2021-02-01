# frozen_string_literal: true

ActiveAdmin.register(BannedPathFragment) do
  permit_params :value, :notes
end
