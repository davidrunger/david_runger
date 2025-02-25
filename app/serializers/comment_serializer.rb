# == Schema Information
#
# Table name: comments
#
#  content    :text             not null
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  parent_id  :bigint
#  path       :string           not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_comments_on_parent_id  (parent_id)
#  index_comments_on_path       (path)
#  index_comments_on_user_id    (user_id)
#
class CommentSerializer < ApplicationSerializer
  attributes :content, :created_at, :id, :parent_id

  one :user, resource: UserSerializer::Public
end
