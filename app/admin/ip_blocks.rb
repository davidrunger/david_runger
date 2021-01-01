# frozen_string_literal: true

ActiveAdmin.register(IpBlock) do
  permit_params :ip, :reason
end
