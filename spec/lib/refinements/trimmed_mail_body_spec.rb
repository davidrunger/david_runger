# frozen_string_literal: true

RSpec.describe TrimmedMailBody do
  using TrimmedMailBody

  subject(:mail) { Mail::Message.new }

  let(:actual_reply_content) { '180.6' }

  before do
    # convert "\n" to "\r\n" because Mailgun seems to send the message with "\r\n"
    # rubocop:disable RSpec/SubjectStub
    expect(mail).to receive(:text_part).and_return(<<~TEXT.gsub(/(?<!\r)\n/, "\r\n"))
      Content-Type: text/plain;
       charset=UTF-8
      Content-Transfer-Encoding: 7bit

      #{actual_reply_content}

      On Sat, Jun 6, 2020 at 10:59 PM David Runger <davidjrunger@gmail.com> wrote:

      > 184.2
      >
      > On Sat, Jun 6, 2020 at 10:58 PM DavidRunger.com <
      > log-reminders@davidrunger.com> wrote:
      >
      >> Submit a new log entry here:
      >>
      >> https://www.davidrunger.com/logs/weight
      >>
      >> *Tip:* To create a log entry, you can simply reply to this email with
      >> the desired log entry content.
      >>
      >
    TEXT
    # rubocop:enable RSpec/SubjectStub
  end

  describe '#trimmed_body' do
    subject(:trimmed_body) { mail.trimmed_body }

    it "returns only the content of the user's most recent message/reply" do
      expect(trimmed_body).to eq(actual_reply_content)
    end
  end
end
