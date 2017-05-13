include FactoryGirl::Syntax::Methods

FixtureBuilder.configure do |fbuilder|
  # rebuild fixtures automatically when these files change:
  fbuilder.files_to_check += Dir['spec/factories/*.rb', 'spec/fixtures.rb']

  fbuilder.factory do
    create(:user)
  end
end
