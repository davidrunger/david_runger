RSpec.describe Features::DownloadHelpers do
  include described_class

  around do |example|
    original_save_path = Capybara.save_path

    Dir.mktmpdir do |tmp_dir|
      Capybara.save_path = tmp_dir
      example.run
    ensure
      Capybara.save_path = original_save_path
    end
  end

  it 'recognizes a download that overwrites a file from an earlier example' do
    csv_path = File.join(Capybara.save_path, 'log.csv')
    File.write(csv_path, 'old CSV')
    @capybara_saved_file_states_before_example = {
      csv_path => capybara_saved_file_state(csv_path),
    }

    File.write(csv_path, 'new,larger CSV')

    expect(downloaded_file_path('*.csv', max_attempts: 1)).to eq(csv_path)
  end

  it 'ignores an unchanged download from an earlier example' do
    csv_path = File.join(Capybara.save_path, 'log.csv')
    File.write(csv_path, 'old CSV')
    @capybara_saved_file_states_before_example = {
      csv_path => capybara_saved_file_state(csv_path),
    }

    expect {
      downloaded_file_path('*.csv', max_attempts: 1)
    }.to raise_error(RuntimeError, /Could not find a file matching '\*\.csv'/)
  end
end
