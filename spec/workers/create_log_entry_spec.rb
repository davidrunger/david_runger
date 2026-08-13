RSpec.describe CreateLogEntry do
  subject(:perform) { described_class.new.perform(log_entry_attributes) }

  let(:log) { Log.number.first! }
  let(:created_at) { 1.hour.ago.change(usec: 0) }
  let(:log_entry_attributes) do
    {
      'log_id' => log.id,
      'created_at' => created_at.as_json,
      'updated_at' => created_at.as_json,
      'data' => 201,
    }
  end

  it 'creates a log entry from structured attributes' do
    expect { perform }.to change { log.reload.log_entries.size }.by(1)
    expect(log.log_entries.last).to have_attributes(data: 201, created_at:)
  end
end
