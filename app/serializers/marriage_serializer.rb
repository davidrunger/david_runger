# frozen_string_literal: true

# == Schema Information
#
# Table name: marriages
#
#  created_at   :datetime         not null
#  id           :bigint           not null, primary key
#  partner_1_id :bigint           not null
#  partner_2_id :bigint
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_marriages_on_partner_1_id  (partner_1_id)
#  index_marriages_on_partner_2_id  (partner_2_id)
#

class MarriageSerializer < ApplicationSerializer
  attributes(*%i[id])
end
