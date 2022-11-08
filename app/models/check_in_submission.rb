# frozen_string_literal: true

# == Schema Information
#
# Table name: check_in_submissions
#
#  check_in_id :bigint           not null
#  created_at  :datetime         not null
#  id          :bigint           not null, primary key
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_check_in_submissions_on_check_in_id_and_user_id  (check_in_id,user_id) UNIQUE
#  index_check_in_submissions_on_user_id                  (user_id)
#

class CheckInSubmission < ApplicationRecord
  belongs_to :check_in
  belongs_to :user

  validates :check_in_id, uniqueness: { scope: :user_id }
end
