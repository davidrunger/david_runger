RSpec.describe LogEntries::EnqueueFromCsv do
  subject(:run) { described_class.new!(csv_path: tempfile.path, log:).run }

  after { tempfile.close }

  let(:log) { users(:user).logs.number.first! }
  let(:csv_rows) { [] }
  let(:tempfile) do
    Tempfile.new('log_data.csv').tap do |file|
      file.write(<<~CSV)
        created_at,data,note
        #{csv_rows.join("\n")}
      CSV
      file.flush
    end
  end

  specify 'an upload can contain at most 10,000 log entries' do
    expect(described_class::MAX_LOG_ENTRIES).to eq(10_000)
  end

  context 'when the data is valid' do
    let(:csv_rows) do
      [
        "#{3.days.ago.iso8601},201,",
        "#{18.hours.ago.iso8601},200,good!",
        "#{1.hour.ago.iso8601},199,not bad",
      ]
    end

    it 'bulk-enqueues one job per row' do
      expect(CreateLogEntry).
        to receive(:perform_bulk).
        with(
          satisfy do |arguments|
            arguments.size == csv_rows.size &&
              arguments.all? do |arguments_for_job|
                arguments_for_job.one? && arguments_for_job.first.is_a?(Hash)
              end
          end,
          batch_size: 1_000,
        ).
        and_call_original

      expect { run }.to change { CreateLogEntry.jobs.size }.by(csv_rows.size)
    end

    it 'enqueues JSON-compatible log entry attributes' do
      run

      attributes = CreateLogEntry.jobs.first.fetch('args').first
      expect(attributes).to include('log_id' => log.id, 'data' => 201)
      expect(JSON.parse(JSON.dump(attributes))).to eq(attributes)
    end

    it 'creates every log entry when the jobs run' do
      expect do
        with_inline_sidekiq { run }
      end.to change { log.reload.log_entries.size }.by(csv_rows.size)
    end
  end

  context 'when the data is invalid' do
    let(:csv_rows) do
      [
        "#{3.days.ago.iso8601},201,",
        "#{18.hours.ago.iso8601},,missing data",
        "#{1.hour.ago.iso8601},199,not bad",
      ]
    end

    it 'fails without enqueueing any jobs' do
      result = nil

      expect { result = run }.not_to change { CreateLogEntry.jobs.size }

      expect(result.error_message).
        to eq('The uploaded data is invalid. We have not entered it in the database.')
    end
  end

  context 'when the upload contains too many log entries' do
    before { stub_const("#{described_class}::MAX_LOG_ENTRIES", 2) }

    let(:csv_rows) do
      [
        "#{3.days.ago.iso8601},201,",
        "#{18.hours.ago.iso8601},200,good!",
        "#{1.hour.ago.iso8601},199,not bad",
      ]
    end

    it 'fails before constructing log entries or enqueueing jobs' do
      expect(log).not_to receive(:build_log_entry_with_datum)
      result = nil

      expect { result = run }.not_to change { CreateLogEntry.jobs.size }

      expect(result.error_message).to eq('Uploads may contain no more than 2 log entries.')
    end
  end
end
