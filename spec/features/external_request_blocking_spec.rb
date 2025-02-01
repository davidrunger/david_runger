RSpec.describe 'Blocking requests to external domains' do
  it 'cannot visit davidrunger.com (when that domain is not allowlisted)' do
    expect { visit 'https://davidrunger.com/' }.
      to raise_error(
        Ferrum::StatusError,
        'Request to https://davidrunger.com/ failed (net::ERR_BLOCKED_BY_CLIENT)',
      )
  end
end
