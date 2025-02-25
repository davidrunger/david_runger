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
class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :parent, class_name: 'Comment', optional: true

  validates :content, presence: true
  validates :path, presence: true
  validate :same_parent_path

  private

  def same_parent_path
    if parent_id && path != parent.path
      errors.add(:path, 'must match parent path')
    end
  end
end
