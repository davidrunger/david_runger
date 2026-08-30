RSpec.describe Features::DownloadHelpers do
  include described_class

  let(:tmp_dir) { Dir.mktmpdir('download_helpers_spec', Capybara.save_path) }
  let(:csv_path) { File.join(tmp_dir, 'log.csv') }
  let(:relative_glob_pattern) { File.join(File.basename(tmp_dir), '*.csv') }

  after { FileUtils.remove_entry(tmp_dir) }

  it 'recognizes a download that overwrites a file from an earlier example' do
    File.write(csv_path, 'old CSV')
    @capybara_saved_file_states_before_example = {
      csv_path => capybara_saved_file_state(csv_path),
    }

    File.write(csv_path, 'new,larger CSV')

    expect(downloaded_file_path(relative_glob_pattern, max_attempts: 1)).to eq(csv_path)
  end

  it 'ignores an unchanged download from an earlier example' do
    File.write(csv_path, 'old CSV')
    @capybara_saved_file_states_before_example = {
      csv_path => capybara_saved_file_state(csv_path),
    }

    expect {
      downloaded_file_path(relative_glob_pattern, max_attempts: 1)
    }.to raise_error(RuntimeError, /Could not find a file matching '.*\*\.csv'/)
  end

  it 'represents file timestamps as ISO 8601 strings with nanosecond precision' do
    File.write(csv_path, 'CSV')

    timestamps = capybara_saved_file_state(csv_path).last(2)

    expect(timestamps).to all(
      match(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{9}(?:Z|[+-]\d{2}:\d{2})\z/),
    )
  end
end
