# frozen_string_literal: true

# == Schema Information
#
# Table name: log_entries
#
#  created_at :datetime         not null
#  data       :jsonb            not null
#  id         :bigint           not null, primary key
#  log_id     :bigint           not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_log_entries_on_log_id  (log_id)
#

RSpec.describe LogEntrySerializer do
  let(:log_entry) { LogEntries::NumberLogEntry.first! }

  specify do
    expect(LogEntrySerializer.new(log_entry).to_json).to match_schema('log_entries/show.json')
  end
end
