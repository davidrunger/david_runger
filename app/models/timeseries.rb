# frozen_string_literal: true

# == Schema Information
#
# Table name: timeseries
#
#  created_at   :datetime         not null
#  id           :bigint           not null, primary key
#  measurements :json             not null
#  name         :text             not null
#  updated_at   :datetime         not null
#
class Timeseries < ApplicationRecord
  validates :name, presence: true
  validates :measurements, presence: true
end
