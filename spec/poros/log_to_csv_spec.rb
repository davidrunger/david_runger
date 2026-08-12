RSpec.describe LogToCsv do
  subject(:log_to_csv) { described_class.new(log, neutralize_formulas:) }

  let(:log) { logs(:text_log) }
  let(:data_label) { '=Label' }
  let(:entry_data) { ['=SUM(A1:A2)', '+cmd', '-cmd', '@cmd'] }
  let(:neutralize_formulas) { true }
  let!(:original_entry_data) do
    log.log_entries.includes(:log_entry_datum).map(&:data)
  end

  describe '#csv_data' do
    subject(:csv_data) do
      CSV.parse(log_to_csv.csv_data)
    end

    before do
      log.update!(data_label:)

      entry_data.each_with_index do |data, index|
        log.build_log_entry_with_datum(data:, created_at: index.minutes.ago).save!
      end
    end

    it 'neutralizes user-controlled string cells with unsafe spreadsheet prefixes' do
      expect(csv_data.first).to eq(['Time', "'=Label"])
      expect(csv_data.drop(1).pluck(1)).to contain_exactly(
        *entry_data.map { "'#{it}" },
        *original_entry_data,
      )
    end

    context 'when formula neutralization is disabled' do
      let(:neutralize_formulas) { false }

      it 'preserves the original strings' do
        expect(csv_data.first).to eq(['Time', '=Label'])
        expect(csv_data.drop(1).pluck(1)).to match_array(original_entry_data + entry_data)
      end
    end

    context 'when an entry contains a negative number' do
      let(:log) { logs(:number_log) }
      let(:data_label) { 'Value' }
      let(:entry_data) { [-1.5] }

      it 'preserves the numeric value' do
        expect(csv_data.drop(1).pluck(1)).to include('-1.5')
      end
    end
  end

  describe '#exported_cell_value' do
    subject(:exported_cell_value) { log_to_csv.send(:exported_cell_value, value) }

    context 'when neutralize_formulas is true' do
      let(:neutralize_formulas) { true }

      [
        "\t=SUM(A1:A2)",
        "\r=SUM(A1:A2)",
        "\n=SUM(A1:A2)",
        ' =SUM(A1:A2)',
      ].each do |leading_whitespace_value|
        context "when a value has leading whitespace (#{leading_whitespace_value.inspect})" do
          let(:value) { leading_whitespace_value }

          it 'neutralizes cells with leading whitespace by prefixing them with an apostrophe' do
            expect(exported_cell_value).to eq("'#{leading_whitespace_value}")
          end
        end
      end
    end
  end
end
