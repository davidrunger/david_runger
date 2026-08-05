class EmailFormatValidator < ActiveModel::EachValidator
  REGEXP = /\A\S+@\S+\.\S+\z/

  def validate_each(record, attribute, value)
    return if value.blank?

    if !REGEXP.match?(value.to_s)
      record.errors.add(attribute, :invalid, value:)
    end
  end
end
