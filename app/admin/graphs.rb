ActiveAdmin.register_page('Graphs') do
  menu parent: 'Admin'

  content do
    h2('home#index response times')
    home_index_response_times =
      Request.
        where(handler: 'home#index').
        where(requested_at: 1.day.ago..).
        where.not(total: nil).
        where('url LIKE ?', "#{DavidRunger::CANONICAL_URL}%").
        where.not('url LIKE ?', '%/?prerender=true').
        pluck(:requested_at, :total)
    div(line_chart(home_index_response_times))
  end
end
