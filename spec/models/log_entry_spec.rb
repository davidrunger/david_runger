RSpec.describe(LogEntry) do
  subject(:log_entry) { LogEntry.first! }

  it { is_expected.to belong_to(:log) }
  it { is_expected.to have_one(:user).through(:log) }

  it { is_expected.to validate_presence_of(:log_entry_datum) }

  describe '#data' do
    subject(:data) { log_entry.data }

    it 'returns the data value from the log_entry_datum' do
      log_entry_datum = log_entry.log_entry_datum

      expect(data).to eq(log_entry_datum.data)
    end
  end

  context 'when destroyed' do
    subject(:destroy!) { log_entry.destroy! }

    it 'also destroys the associated log_entry_datum' do
      log_entry_datum = log_entry.log_entry_datum

      expect {
        destroy!
      }.to change {
        log_entry.log_entry_datum_type.constantize.exists?(log_entry_datum.id)
      }.from(true).to(false)
    end
  end
end
