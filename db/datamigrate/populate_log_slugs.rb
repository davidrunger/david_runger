# frozen_string_literal: true

def populate_log_slugs
  Log.find_each do |log|
    log.set_slug
    log.save!
  end
end
