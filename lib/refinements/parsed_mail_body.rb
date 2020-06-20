# frozen_string_literal: true

module ParsedMailBody
  refine Mail::Message do
    def parsed_body
      # call #dup because ::trim modifies the string (via at least one `#gsub!` call)
      unparsed_body = (text_part.presence || body).to_s.dup
      # trim content from the end of the body ("On [date/time] [person/email] wrote:[...]")
      EmailReplyTrimmer.trim(unparsed_body).rstrip.
        # trim header content from the beginning of the body
        sub(/\A[\s\S]*^Content-Transfer-Encoding:.+\n+/, '').
        # remove newlines that were added just to break up long lines
        gsub(/\S+\n\S+/) do |match|
          word_before_newline = match.split("\n").first
          if word_before_newline.in?(words_truly_before_newlines)
            # leave the newline in if the user intends for the word to be followed by a newline
            match
          else
            # otherwise, change the newline to a space (i.e. recombine the wrapped lines)
            match.tr("\n", ' ')
          end
        end
    end

    private

    # this method tries to determine words that the user _actually_ put before a newline, based on
    # the idea that such words will be followed by a `<` character (from a `<br>` or a `</div>`)
    def words_truly_before_newlines
      @words_truly_before_newlines ||=
        begin
          decoded_html =
            (html_part || '').
              to_s.
              sub(/\A[\s\S]*^Content-Transfer-Encoding:.+[\r\n]+/, '').
              unpack1('M').
              delete("\r").
              rstrip
          nokogiri_doc = Nokogiri.parse(decoded_html)
          nokogiri_doc.css('.gmail_quote').remove
          Set.new(nokogiri_doc.to_s.scan(/[^<>\s]+(?=<)/))
        end
    end
  end
end
