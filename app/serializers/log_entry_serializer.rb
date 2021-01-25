# frozen_string_literal: true

# rubocop:disable Layout/LineLength
# == Schema Information
#
# Table name: log_entries
#
#  created_at        :datetime         not null
#  data_logable_id   :bigint           not null
#  data_logable_type :string           not null
#  id                :bigint           not null, primary key
#  log_id            :bigint           not null
#  note              :text
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_log_entries_on_data_logable_id_and_data_logable_type  (data_logable_id,data_logable_type) UNIQUE
#  index_log_entries_on_log_id                                 (log_id)
#
# rubocop:enable Layout/LineLength

class LogEntrySerializer < ActiveModel::Serializer
  attributes :id, :created_at, :data, :log_id, :note

  def created_at
    log_entry.read_attribute_before_type_cast('created_at').iso8601
  end

  def data
    log_entry.data_logable.value
  end

  private

  def log_entry
    object
  end
end
