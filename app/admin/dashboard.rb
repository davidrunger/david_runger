ActiveAdmin.register_page('Dashboard') do
  menu priority: 1, label: 'Dashboard'

  content title: 'Dashboard' do
    panel 'Admin Tools' do
      h3 { b { link_to('Blazer', '/blazer') } }
      h3 { b { link_to('Flipper', '/flipper') } }
      h3 { b { link_to('Model Graph', '/models') } }
      h3 { b { link_to('PgHero', '/pghero') } }
      h3 { b { link_to('Sidekiq', '/sidekiq') } }
      h3 { b { link_to('Vue Playground', '/vue-playground') } }
    end
  end
end
