RSpec.describe 'proposal routes' do
  it 'routes confirmation viewing through GET' do
    expect(get: '/proposals/public-id/confirm').
      to route_to(controller: 'proposals', action: 'confirm', public_id: 'public-id')
  end

  it 'routes acceptance through POST' do
    expect(post: '/proposals/public-id/accept').
      to route_to(controller: 'proposals', action: 'accept', public_id: 'public-id')
  end

  it 'does not route acceptance through GET' do
    expect(get: '/proposals/public-id/accept').not_to be_routable
  end

  it 'routes cancellation through POST' do
    expect(post: '/proposals/public-id/cancel').
      to route_to(controller: 'proposals', action: 'cancel', public_id: 'public-id')
  end

  it 'does not route cancellation through GET' do
    expect(get: '/proposals/public-id/cancel').not_to be_routable
  end
end
