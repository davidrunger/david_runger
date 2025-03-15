ActiveAdmin.register_page('Dashboard') do
  menu priority: 1, label: 'Dashboard'

  content title: 'Dashboard' do
    columns do
      column do
        panel 'Admin Tools' do
          h3 { b { link_to('Blazer', '/blazer') } }
          h3 { b { link_to('Flipper', '/flipper') } }
          h3 { b { link_to('PgHero', '/pghero') } }
          h3 { b { link_to('Sidekiq', '/sidekiq') } }
          h3 { b { link_to('Vue Playground', '/vue-playground') } }
        end
      end

      column do
        panel 'Recent Users' do
          table_for User.order(created_at: :desc).first(3) do
            column(:id) { |user| link_to(user.id, admin_user_path(user)) }
            column(:email) { |user| link_to(user.email, admin_user_path(user)) }
            column(:created_at)
          end
        end
      end

      column do
        panel 'Reminder' do
          para 'You are beautiful.'
        end
      end
    end
  end
end
