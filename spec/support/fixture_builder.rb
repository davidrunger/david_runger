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
    user = name(:user, create(:user)).first
    store = name(:store, create(:store, user: user)).first
    create(:item, store: store)
    name(:weight_log, create(:weight_log, user: user))
    chin_ups = name(:chin_ups, create(:exercise, user: user)).first
    name(:chin_ups_count_log, create(:exercise_count_log, exercise: chin_ups))
  end
end
