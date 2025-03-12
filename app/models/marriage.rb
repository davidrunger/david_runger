# == Schema Information
#
# Table name: marriages
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  updated_at :datetime         not null
#
class Marriage < ApplicationRecord
  has_many :check_ins, dependent: :destroy
  has_many :emotional_needs, dependent: :destroy
  has_many :memberships, dependent: :destroy, class_name: 'MarriageMembership'
  has_many :partners, through: :memberships, source: :user

  has_paper_trail
end
