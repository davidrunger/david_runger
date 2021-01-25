# frozen_string_literal: true

# == Schema Information
#
# Table name: numeric_data
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  updated_at :datetime         not null
#  value      :float            not null
#

class NumericDatum < ApplicationRecord
  include DataLogable

  validates :value, presence: true
end
