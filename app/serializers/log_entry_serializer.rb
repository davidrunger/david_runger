# == Schema Information
#
# Table name: log_entries
#
#  created_at :datetime         not null
#  data       :jsonb            not null
#  id         :bigint(8)        not null, primary key
#  log_id     :bigint(8)        not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_log_entries_on_log_id  (log_id)
#

class LogEntrySerializer < ActiveModel::Serializer
  attributes :id, :created_at, :data

  def created_at
    # TODO: change this so it doesn't necessitate a #reload in Api::LogEntriesController#create
    "#{log_entry.read_attribute_before_type_cast('created_at')}Z"
  end

  private

  def log_entry
    object
  end
end
