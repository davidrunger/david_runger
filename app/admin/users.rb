# frozen_string_literal: true

ActiveAdmin.register(User) do
  menu parent: 'Users'
  permit_params :email, :phone, :sms_allowance
end
