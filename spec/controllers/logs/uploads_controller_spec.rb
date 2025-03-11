RSpec.describe Logs::UploadsController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#new' do
    subject(:get_new) { get(:new) }

    it 'renders a form to upload log entry data for a selected log and tips for usage' do
      get_new

      expect(response.body).to have_css("form[action='#{logs_uploads_path}'][method='post']")
      expect(response.body).to have_css('form select[name=log_id]')
      expect(response.body).to have_css('form input[type=file]')
      expect(response.body).to have_text('Recommended CSV columns')
    end
  end

  describe '#create' do
    subject(:post_create) { post(:create, params: { log_id: log.id, csv: csv_file }) }

    after { tempfile.close }

    let(:log) { user.logs.number.first! }
    let(:tempfile) { Tempfile.new('log_data.csv') }
    let(:csv_file) do
      # https://rubyquicktips.com/post/27753730620/testing-csv-file-uploads
      csv_content = <<~CSV
        created_at,data,note
        #{csv_rows.join("\n")}
      CSV

      tempfile.write(csv_content)
      tempfile.rewind

      Rack::Test::UploadedFile.new(tempfile, 'text/csv')
    end

    context 'when the data being uploaded is valid' do
      let(:csv_rows) do
        [
          "#{3.days.ago.iso8601},201,",
          "#{18.hours.ago.iso8601},200,good!",
          "#{1.hour.ago.iso8601},199,not bad",
        ]
      end

      it 'creates log entries' do
        expect do
          with_inline_sidekiq do
            post_create
          end
        end.to change { log.reload.log_entries.size }.by(csv_rows.size)

        expect(response).to redirect_to(log_path(log))
        expect(flash[:notice]).to match(/Data uploaded successfully!/)
      end
    end

    context 'when the data being uploaded is not valid' do
      let(:csv_rows) do
        [
          "#{3.days.ago.iso8601},201,",
          "#{18.hours.ago.iso8601},,<= THIS ROW IS MISSING A DATA VALUE!",
          "#{1.hour.ago.iso8601},199,not bad",
        ]
      end

      it 'does not create any log entries' do
        expect do
          Sidekiq::Testing.inline! do
            post_create
          end
        end.not_to change { log.reload.log_entries.size }

        expect(response).to redirect_to(logs_uploads_path)
        expect(flash[:alert]).to match(/The uploaded data is invalid/)
      end
    end
  end
end
