# NOTE: We need to register with a name other than Comment to avoid conflicts
# with ActiveAdmin::Comment.
ActiveAdmin.register(Comment, as: 'BlogComment') do
  includes :parent, :user
end
