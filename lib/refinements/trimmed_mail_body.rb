# frozen_string_literal: true

module TrimmedMailBody
  refine Mail::Message do
    def trimmed_body
      # call #dup because #trim modifies the string (via at least one `#gsub!` call)
      untrimmed_body = (text_part.presence || body).to_s.dup
      # first, trim content from the end of the body ("On [date/time] [person/email] wrote:[...]")
      EmailReplyTrimmer.trim(untrimmed_body).rstrip.
        # then, trim header content from the beginning of the body
        sub(/\A[\s\S]*^Content-Transfer-Encoding:.+\n+/, '')
    end
  end
end
