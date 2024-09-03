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
class Log < ApplicationRecord
  DATA_TYPES = {
    'counter' => {
      datum_class: NumberLogEntryDatum,
    },
    'duration' => {
      datum_class: TextLogEntryDatum,
    },
    'number' => {
      datum_class: NumberLogEntryDatum,
    },
    'text' => {
      datum_class: TextLogEntryDatum,
    },
  }.transform_keys(&:freeze).transform_values(&:freeze).freeze

  validates :data_label, presence: true
  validates :data_type, presence: true, inclusion: DATA_TYPES.keys
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :slug, presence: true, uniqueness: { scope: :user_id }

  belongs_to :user

  has_many :log_entries, dependent: :destroy, inverse_of: :log
  has_many :log_shares, dependent: :destroy, inverse_of: :log

  before_validation :set_slug, if: -> { name_changed? }

  DATA_TYPES.each_key do |data_type|
    scope(data_type, -> { where(data_type:) })
  end

  scope :needing_reminder,
    -> {
      left_joins(:log_entries).
        where.not(reminder_time_in_seconds: nil).
        group('logs.id').
        having(<<~SQL.squish)
          (
            MAX(log_entries.created_at) IS NULL
            AND logs.reminder_last_sent_at IS NULL
            AND EXTRACT(EPOCH FROM (NOW() - logs.created_at)) > logs.reminder_time_in_seconds
          )
          OR
          (
            MAX(log_entries.created_at) IS NOT NULL
            AND (logs.reminder_last_sent_at IS NULL OR logs.reminder_last_sent_at < MAX(log_entries.created_at))
            AND EXTRACT(EPOCH FROM (NOW() - MAX(log_entries.created_at))) >= logs.reminder_time_in_seconds
          )
        SQL
    }

  def set_slug
    self.slug = name.downcase.gsub(%r{\s+|\.+|\\|/}, '-').gsub(/[^[:alnum:]\-_]/, '')
  end

  def to_param
    slug
  end

  def log_entry_datum_class
    DATA_TYPES[data_type][:datum_class]
  end

  def build_log_entry_with_datum(params)
    log_entries.build.tap do |log_entry|
      if params.respond_to?(:symbolize_keys)
        params = params.symbolize_keys
      end

      log_entry.assign_attributes(params.except(:data))
      log_entry.log_entry_datum = log_entry_datum_class.new(data: params[:data])
    end
  end
end
