# frozen_string_literal: true

# == Schema Information
#
# Table name: logs
#
#  created_at  :datetime         not null
#  data_label  :string           not null
#  data_type   :string           not null
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
  DATA_TYPES = {
    'counter' => {
      association: :number_log_entries,
      ordered_association: :number_log_entries_ordered,
    },
    'duration' => {
      association: :text_log_entries,
      ordered_association: :text_log_entries_ordered,
    },
    'number' => {
      association: :number_log_entries,
      ordered_association: :number_log_entries_ordered,
    },
    'text' => {
      association: :text_log_entries,
      ordered_association: :text_log_entries_ordered,
    },
  }.transform_keys(&:freeze).transform_values(&:freeze).freeze

  validates :data_label, presence: true
  validates :data_type, presence: true, inclusion: DATA_TYPES.keys
  validates :name, presence: true, uniqueness: {scope: :user_id}

  belongs_to :user

  has_many :number_log_entries,
    class_name: 'LogEntries::NumberLogEntry',
    dependent: :destroy,
    inverse_of: :log
  has_many :number_log_entries_ordered,
    -> { order(:created_at) },
    class_name: 'LogEntries::NumberLogEntry',
    dependent: :destroy,
    inverse_of: :log

  has_many :text_log_entries,
    class_name: 'LogEntries::TextLogEntry',
    dependent: :destroy,
    inverse_of: :log
  has_many :text_log_entries_ordered,
    -> { order(:created_at) },
    class_name: 'LogEntries::TextLogEntry',
    dependent: :destroy,
    inverse_of: :log

  has_many :log_shares, dependent: :destroy

  before_save :set_slug, if: -> { name_changed? }

  def log_entries
    public_send(DATA_TYPES[data_type][:association])
  end

  def log_entries_ordered
    public_send(DATA_TYPES[data_type][:ordered_association])
  end

  def set_slug
    self.slug = name.downcase.gsub(%r{\s+|\.+|\\|/}, '-').gsub(/[^[:alnum:]\-_]/, '')
  end
end
