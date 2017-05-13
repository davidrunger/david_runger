# == Schema Information
#
# Table name: templates
#
#  body       :string
#  created_at :datetime         not null
#  id         :integer          not null, primary key
#  name       :string
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_templates_on_user_id  (user_id)
#

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
