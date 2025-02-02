ActiveAdmin.register(Event) do
  includes :admin_user, :user
end
