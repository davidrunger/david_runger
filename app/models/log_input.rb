# == Schema Information
#
# Table name: log_inputs
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  index      :integer          default(0), not null
#  label      :string           not null
#  log_id     :bigint(8)        not null
#  type       :string           not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_log_inputs_on_log_id_and_index  (log_id,index) UNIQUE
#

class LogInput < ApplicationRecord
  PUBLIC_TYPE_TO_TYPE_MAPPING = {
    integer: LogInputs::IntegerLogInput.name,
    duration: LogInputs::DurationLogInput.name,
  }.with_indifferent_access.freeze

  TYPE_TO_PUBLIC_TYPE_MAPPING = PUBLIC_TYPE_TO_TYPE_MAPPING.invert.freeze

  belongs_to :log
  validates :label, presence: true
  validates :type, presence: true
  validates :index, presence: true, uniqueness: {scope: :log_id}

  def public_type
    TYPE_TO_PUBLIC_TYPE_MAPPING[type]
  end

  def public_type=(public_type)
    self.type = PUBLIC_TYPE_TO_TYPE_MAPPING.fetch(public_type)
  end
end
