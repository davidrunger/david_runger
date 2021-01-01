# frozen_string_literal: true

ActiveAdmin.register_page('Dashboard') do
  menu priority: 1, label: 'Dashboard'

  content title: 'Dashboard' do
    columns do
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
        panel 'Recent IP Blocks' do
          table_for IpBlock.order(created_at: :desc).first(3) do
            column(:ip) { |ip_block| link_to(ip_block.ip, admin_ip_block_path(ip_block)) }
            column(:reason) { |ip_block| truncate(ip_block.reason.split("\n").first, length: 15) }
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
