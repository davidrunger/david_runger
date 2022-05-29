# frozen_string_literal: true

class Timeseries < ApplicationRecord
  validates :name, presence: true
  validates :measurements, presence: true
end
