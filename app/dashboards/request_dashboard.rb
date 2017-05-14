require "administrate/base_dashboard"

class RequestDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    id: Field::Number,
    url: Field::String,
    handler: Field::String,
    referer: Field::String,
    params: Field::String.with_options(searchable: false),
    method: Field::String,
    format: Field::String,
    status: Field::Number,
    view: Field::Number,
    db: Field::Number,
    ip: Field::String,
    user_agent: Field::String,
    requested_at: Field::DateTime,
    bot: Field::Boolean,
    location: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :user,
    :handler,
    :bot,
    :requested_at,
    :location,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :user,
    :id,
    :url,
    :handler,
    :referer,
    :params,
    :method,
    :format,
    :status,
    :view,
    :db,
    :ip,
    :user_agent,
    :requested_at,
    :bot,
    :location,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :user,
    :url,
    :handler,
    :referer,
    :params,
    :method,
    :format,
    :status,
    :view,
    :db,
    :ip,
    :user_agent,
    :requested_at,
    :bot,
  ].freeze

  # Overwrite this method to customize how requests are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(request)
  #   "Request ##{request.id}"
  # end
end
