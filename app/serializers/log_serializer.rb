# == Schema Information
#
# Table name: logs
#
#  created_at               :datetime         not null
#  data_label               :string           not null
#  data_type                :string           not null
#  description              :string
#  id                       :bigint           not null, primary key
#  name                     :string           not null
#  publicly_viewable        :boolean          default(FALSE), not null
#  reminder_last_sent_at    :datetime
#  reminder_time_in_seconds :integer
#  slug                     :string           not null
#  updated_at               :datetime         not null
#  user_id                  :bigint           not null
#
# Indexes
#
#  index_logs_on_user_id_and_name  (user_id,name) UNIQUE
#  index_logs_on_user_id_and_slug  (user_id,slug) UNIQUE
#
class LogSerializer < ApplicationSerializer
  attributes(*%i[
    data_label
    data_type
    description
    id
    name
    slug
  ])

  attributes(
    *%w[
      publicly_viewable
      reminder_time_in_seconds
    ],
    if: :own_logs?,
  )

  one :user, resource: UserSerializer::Basic
  many :log_shares, resource: LogShareSerializer, if: :own_logs?

  private

  def own_logs?
    logs.map(&:user_id).uniq == [current_user.id]
  end

  def logs
    Array(object)
  end
end
