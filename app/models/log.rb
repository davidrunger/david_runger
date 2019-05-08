# == Schema Information
#
# Table name: logs
#
#  created_at  :datetime         not null
#  description :string
#  id          :bigint           not null, primary key
#  name        :string           not null
#  slug        :string           not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_logs_on_user_id_and_name  (user_id,name) UNIQUE
#  index_logs_on_user_id_and_slug  (user_id,slug) UNIQUE
#

class Log < ApplicationRecord
  validates :name, presence: true, uniqueness: {scope: :user_id}

  belongs_to :user

  has_many :log_entries, dependent: :destroy
  has_many :log_entries_ordered,
    -> { order(:created_at) },
    class_name: 'LogEntry',
    dependent: :destroy,
    inverse_of: :log
  has_many :log_inputs, dependent: :destroy

  accepts_nested_attributes_for :log_inputs

  before_save :set_slug, if: -> { name_changed? }

  def set_slug
    self.slug = name.downcase.gsub(/\s+|\.+|\\|\//, '-').gsub(/[^[:alnum:]\-_]/, '')
  end
end
