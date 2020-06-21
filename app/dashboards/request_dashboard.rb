# frozen_string_literal: true

require 'administrate/base_dashboard'

class RequestDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    auth_token: Field::BelongsTo,
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
    ip: IpAddressField,
    user_agent: UserAgentField,
    requested_at: BriefTimeField,
    request_id: PapertrailSearchField,
    location: Field::String,
    isp: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    user
    auth_token
    handler
    requested_at
    location
    isp
    user_agent
    ip
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    user
    auth_token
    url
    handler
    referer
    params
    method
    format
    status
    view
    db
    ip
    isp
    user_agent
    requested_at
    request_id
    location
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    user
    url
    handler
    referer
    params
    method
    format
    status
    view
    db
    ip
    user_agent
    requested_at
  ].freeze

  # Overwrite this method to customize how requests are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(request)
  #   "Request ##{request.id}"
  # end
end
