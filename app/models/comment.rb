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
#  user_id    :bigint
#
# Indexes
#
#  index_comments_on_parent_id  (parent_id)
#  index_comments_on_path       (path)
#  index_comments_on_user_id    (user_id)
#
class Comment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :parent, class_name: 'Comment', optional: true
  has_many :children,
    class_name: 'Comment',
    foreign_key: :parent_id,
    dependent: :restrict_with_exception,
    inverse_of: :parent

  validates :content, presence: true
  validates :path, presence: true
  validate :same_parent_path

  class << self
    def ransackable_associations(_auth_object = nil)
      %w[children parent user]
    end

    def ransackable_attributes(_auth_object = nil)
      %w[content created_at id id_value parent_id path updated_at user_id]
    end
  end

  private

  def same_parent_path
    if parent_id && path != parent.path
      errors.add(:path, 'must match parent path')
    end
  end
end
