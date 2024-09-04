module LogEntryDatum
  extend ActiveSupport::Concern

  included do
    has_one :log_entry, as: :log_entry_datum, touch: true, dependent: :destroy

    validates :data, presence: true
    validates :log_entry, presence: true
  end
end
