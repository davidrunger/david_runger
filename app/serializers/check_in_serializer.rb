# frozen_string_literal: true

# == Schema Information
#
# Table name: check_ins
#
#  created_at  :datetime         not null
#  id          :bigint           not null, primary key
#  marriage_id :bigint           not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_check_ins_on_marriage_id  (marriage_id)
#
class CheckInSerializer < ApplicationSerializer
  attributes :id
end
