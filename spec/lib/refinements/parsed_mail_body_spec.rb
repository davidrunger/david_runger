# frozen_string_literal: true

RSpec.describe ParsedMailBody do
  using ParsedMailBody

  subject(:mail) { Mail::Message.new }

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

  describe '#parsed_body' do
    subject(:parsed_body) { mail.parsed_body }

    context 'when the actual content is a single line of text' do
      let(:actual_reply_content) { '180.6' }

      it "returns only the content of the user's most recent message/reply" do
        expect(parsed_body).to eq(actual_reply_content)
      end
    end

    context 'when the actual content is multiple lines of text' do
      let(:actual_reply_content) do
        <<~EMAIL_BODY
          Hi there,

          This is a long paragraph that gets split onto multiple lines because email
          standards say that the line width should not be more than 78 characters,
          including newlines.

          This is another, shorter paragraph.

          Sincerely,
          David
        EMAIL_BODY
      end

      before do
        # convert "\n" to "\r\n" because Mailgun seems to send the message with "\r\n"
        expect(mail).to receive(:html_part).and_return(<<~HTML_PART.gsub(/(?<!\r)\n/, "\r\n"))
          Content-Type: text/html;
           charset=UTF-8
          Content-Transfer-Encoding: quoted-printable

          <div dir=3D"ltr">Hi there,<br><br>This is a long paragraph that gets spli=
          t onto multiple lines because email standards say that the line width sho=
          uld not be more than 78 characters, including newlines.<br><br>This is an=
          other, shorter paragraph.<br><br>Sincerely,<br>David</div><br><div class=3D=
          "gmail_quote"><div dir=3D"ltr" class=3D"gmail_attr">On Wed, Jun 17, 2020 =
          at 10:11 AM DavidRunger.com &lt;<a href=3D"mailto:log-reminders@davidrung=
          er.com">log-reminders@davidrunger.com</a>&gt; wrote:<br></div><blockquote=
           class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px =
          solid rgb(204,204,204);padding-left:1ex"><u></u>=0D
          =0D
            =0D
              =0D
              =0D
            =0D
          =0D
            <div>=0D
              <p>Submit a new log entry here:</p>=0D
          <p><a href=3D"https://www.davidrunger.com/logs/gratitude-journal" target=3D=
          "_blank">https://www.davidrunger.com/logs/gratitude-journal</a></p>=0D
          <p>=0D
          <b>Tip:</b>=0D
          To create a log entry, you can simply reply to this email with the desire=
          d log entry content.=0D
          </p>=0D
          =0D
            </div>=0D
          =0D
          </blockquote></div>=0D
        HTML_PART
      end

      it "returns the user's most recent message/reply with newlines in the proper places" do
        parsed_lines = parsed_body.split("\n")

        expect(parsed_lines[0]).to eq('Hi there,')
        expect(parsed_lines[1]).to eq('')
        expect(parsed_lines[2]).to match(/\AThis is a long paragraph.*including newlines.\z/)
        expect(parsed_lines[3]).to eq('')
        expect(parsed_lines[4]).to eq('This is another, shorter paragraph.')
        expect(parsed_lines[5]).to eq('')
        expect(parsed_lines[6]).to eq('Sincerely,')
        expect(parsed_lines[7]).to eq('David')
      end
    end
  end
end
