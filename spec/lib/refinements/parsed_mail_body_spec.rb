RSpec.describe Refinements::ParsedMailBody do
  include MailSpecHelpers

  using Refinements::ParsedMailBody

  let(:mail) { Mail::Message.new }

  before do
    # convert "\n" to "\r\n" because Mailgun seems to send the message with "\r\n"
    expect(mail).to receive(:text_part) do
      <<~TEXT.gsub(/(?<!\r)\n/, "\r\n")
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
    end
  end

  describe '#parsed_body' do
    subject(:parsed_body) { mail.parsed_body }

    context 'when the actual content is a single line of text' do
      let(:actual_reply_content) { '180.6' }

      it "returns only the content of the user's most recent message/reply" do
        expect(parsed_body).to eq(actual_reply_content)
      end
    end

    context 'when the actual content is multiple lines of text (case A)' do
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

    context 'when the actual content is multiple lines of text (case B)' do
      let(:actual_reply_content) do
        <<~EMAIL_BODY
          1. my abcdefg, e.g. asdfh aasdf asdflkjasdf asksj or a (asdfjasdfkjasfd)
          shsfdhs asf asfsfsfj
          2. asdhasdf asdfasdfsf on the vahsuhsu asfsfss
          3. asdf asdfasdf Bsdasjsfsdf BBSFBsf asdfasdss evening (asdfas sasfsfss has
          any asdfasdfasdf asdfasdf ashsh, which, asfsily, asdfasdf!)
        EMAIL_BODY
      end

      before do
        # convert "\n" to "\r\n" because Mailgun seems to send the message with "\r\n"
        expect(mail).to receive(:html_part).and_return(<<~HTML_PART.gsub(/(?<!\r)\n/, "\r\n"))
          Content-Type: text/html;
           charset=UTF-8
          Content-Transfer-Encoding: quoted-printable

          <div dir=3D"ltr">1. my abcdefg, e.g. asdfh aasdf asdflkjasdf asksj or a (=
          asdfjasdfkjasfd) shsfdhs asf asfsfsfj<div>2. asdhasdf asdfasdfsf on the v=
          ahsuhsu asfsfss</div><div>3. asdf asdfasdf Bsdasjsfsdf BBSFBsf asdfasdss =
          evening (asdfas sasfsfss has any asdfasdfasdf asdfasdf ashsh, which, asfs=
          ily, asdfasdf!)</div></div><br><div class=3D"gmail_quote"><div dir=3D"ltr=
          " class=3D"gmail_attr">On Thu, Jul 16, 2020 at 3:20 PM DavidRunger.com &l=
          t;<a href=3D"mailto:log-reminders@davidrunger.com">log-reminders@davidrun=
          ger.com</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" style=3D=
          "margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-=
          left:1ex"><u></u>=0D
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

        expect(parsed_lines.size).to eq(3)

        expect(parsed_lines[0]).to eq(<<~LINE.squish)
          1. my abcdefg, e.g. asdfh aasdf asdflkjasdf asksj or a (asdfjasdfkjasfd) shsfdhs asf
             asfsfsfj
        LINE
        expect(parsed_lines[1]).to eq('2. asdhasdf asdfasdfsf on the vahsuhsu asfsfss')
        expect(parsed_lines[2]).to eq(<<~LINE.squish)
          3. asdf asdfasdf Bsdasjsfsdf BBSFBsf asdfasdss evening (asdfas sasfsfss has any
             asdfasdfasdf asdfasdf ashsh, which, asfsily, asdfasdf!)
        LINE
      end
    end

    context 'when the email body is empty' do
      before { RSpec::Mocks.space.proxy_for(mail).reset }

      let(:mail) { mail_from_raw_email_fixture('empty_body') }

      it 'returns nil' do
        expect(parsed_body).to eq(nil)
      end
    end

    context 'when the email body has lines that get split up' do
      before { RSpec::Mocks.space.proxy_for(mail).reset }

      let(:mail) { mail_from_raw_email_fixture('multiline') }

      it 'parses the email into the correct lines' do
        parsed_lines = parsed_body.split("\n")

        expect(parsed_lines.size).to eq(3)

        expect(parsed_lines[0]).to eq(<<~LINE.squish)
          1. my work monitor is working pretty well
        LINE
        expect(parsed_lines[1]).to eq(<<~LINE.squish)
          2. we haven't had any major maintenance issues with the house we're renting
        LINE
        expect(parsed_lines[2]).to eq(<<~LINE.squish)
          3. Mom and Dad came to visit and were very generous with their time and decently generous
          with their money
        LINE
      end

      it 'does not include info about the original email' do
        expect(parsed_body).not_to include('wrote:')
      end
    end
  end
end
