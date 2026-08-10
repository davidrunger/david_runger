RSpec.describe LogToCsv do
  subject(:csv_rows) do
    CSV.parse(described_class.new(log, neutralize_formulas:).csv_data)
  end

  let(:log) { logs(:text_log) }
  let(:data_label) { '=Label' }
  let(:entry_data) { ['=SUM(A1:A2)', '+cmd', '-cmd', '@cmd'] }
  let(:neutralize_formulas) { true }
  let!(:original_entry_data) do
    log.log_entries.includes(:log_entry_datum).map(&:data)
  end

  before do
    log.update!(data_label:)

    entry_data.each_with_index do |data, index|
      log.build_log_entry_with_datum(data:, created_at: index.minutes.ago).save!
    end
  end

  it 'neutralizes formulas in user-controlled string cells' do
    expect(csv_rows.first).to eq(['Time', "'=Label"])
    expect(csv_rows.drop(1).pluck(1)).to contain_exactly(
      "'=SUM(A1:A2)",
      "'+cmd",
      "'-cmd",
      "'@cmd",
      *original_entry_data,
    )
  end

  context 'when formula neutralization is disabled' do
    let(:neutralize_formulas) { false }

    it 'preserves the original strings' do
      expect(csv_rows.first).to eq(['Time', '=Label'])
      expect(csv_rows.drop(1).pluck(1)).to match_array(original_entry_data + entry_data)
    end
  end

  context 'when an entry contains a negative number' do
    let(:log) { logs(:number_log) }
    let(:data_label) { 'Value' }
    let(:entry_data) { [-1.5] }

    it 'preserves the numeric value' do
      expect(csv_rows.drop(1).pluck(1)).to include('-1.5')
    end
  end
end
