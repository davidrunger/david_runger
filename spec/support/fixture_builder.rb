include FactoryGirl::Syntax::Methods

FixtureBuilder.configure do |fbuilder|
  # rebuild fixtures automatically when these files change:
  fbuilder.files_to_check += Dir[
    'spec/factories/*.rb',
    'spec/fixtures.rb',
    'spec/support/fixture_builder.rb',
  ]

  fbuilder.factory do
    user = name(:user, create(:user)).first
    create(:store, user: user)
  end
end
