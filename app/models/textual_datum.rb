# frozen_string_literal: true

# == Schema Information
#
# Table name: textual_data
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  updated_at :datetime         not null
#  value      :text             not null
#

class TextualDatum < ApplicationRecord
  include DataLogable

  validates :value, presence: true
end
