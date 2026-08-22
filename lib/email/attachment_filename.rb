class Email::AttachmentFilename
  FALLBACK = 'attachment'

  class << self
    def sanitize(filename)
      basename = File.basename(utf8_filename(filename).delete("\0").tr('\\', '/'))
      sanitized_basename = ActiveStorage::Filename.new(basename).sanitized.gsub(/[[:cntrl:]]/, '-')

      if sanitized_basename.blank? || sanitized_basename.in?(['.', '..'])
        FALLBACK
      else
        sanitized_basename
      end
    end

    private

    def utf8_filename(filename)
      filename.to_s.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: '�')
    end
  end
end
