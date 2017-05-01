class Template < ApplicationRecord
  SAMPLE_BODY = <<~TEMPLATE
    Example:

    Hi {name}! :)

    I'd like to speak with you about {topic}, when you have a chance. Please call me at 123-555-1234 to discuss.

    Best,
    David Runger
  TEMPLATE

  validates :name, presence: true
end
