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

RSpec.describe LogEntrySerializer do
  let(:log_entry) { LogEntry.first! }

  specify do
    expect(
      LogEntrySerializer.new(log_entry).to_json,
    ).to match_schema('spec/support/schemas/log_entries/show.json')
  end
end
