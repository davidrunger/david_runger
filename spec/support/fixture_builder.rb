# frozen_string_literal: true

# rubocop:disable Style/MixinUsage
include FactoryBot::Syntax::Methods
# rubocop:enable Style/MixinUsage

FixtureBuilder.configure do |fbuilder|
  # rebuild fixtures automatically when these files change:
  fbuilder.files_to_check += Dir[
    'spec/factories/*.rb',
    'spec/fixtures.rb',
    'spec/support/fixture_builder.rb',
  ]

  fbuilder.factory do
    # user
    user = name(:user, create(:user)).first

    # groceries
    store = name(:store, create(:store, user: user)).first
    name(:item, create(:item, store: store))

    # logs
    log = name(:log, create(:log, user: user)).first
    log.log_entries.create!(data: 102, note: 'I am glad it is an even number')
  end
end
