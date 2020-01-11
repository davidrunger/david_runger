# frozen_string_literal: true

RSpec.describe 'Home page' do
  it 'says "David Runger / Full stack web developer"', :js do
    visit root_path
    expect(page).to have_text(<<~HEADLINE)
      David Runger
      Full stack web developer
    HEADLINE
  end
end
