RSpec.describe 'proposing marriage to another user' do
  subject(:visit_new_marriage_path) { visit(new_marriage_path) }

  context 'when a user is signed in' do
    before { sign_in(user) }

    let(:user) { users(:user) }
    let(:marriage) { user.marriage }

    context 'when the user is not yet in a marriage with a partner' do
      before do
        expect(marriage.partners.first!).to eq(user)
        marriage.memberships.where.not(user_id: user).find_each(&:destroy!)
        expect(marriage.reload.partners.size).to eq(1)
      end

      let(:proposee) { User.where.not(id: user).first! }

      context 'when JWT_SECRET is set' do
        before { expect(ENV.fetch('JWT_SECRET', nil)).to be_present }

        it 'allows inviting a spouse and allows the spouse to accept the proposal' do
          visit_new_marriage_path

          expect(page).to have_text('Enter the email of your spouse')

          fill_in('spouse_email', with: proposee.email)

          with_inline_sidekiq do
            activate_feature!(:disable_fetch_ip_info_for_request_worker)
            num_emails_before = ActionMailer::Base.deliveries.size
            click_on('Submit')

            expect(page).to have_flash_message('Invitation sent.')

            wait_for { ActionMailer::Base.deliveries.size }.to eq(num_emails_before + 1)
          end

          # log in proposee and accept the proposal
          Capybara.using_session('proposee') do
            wait_for do
              sign_in(proposee)
              sign_in_confirmed_via_my_account?(proposee)
            end.to eq(true)

            open_email(proposee.email)
            # rubocop:disable RungerStyle/ClickAmbiguously
            current_email.click_link('Click here', href: %r{/proposals/accept\?token=.+})
            # rubocop:enable RungerStyle/ClickAmbiguously
            expect(page).to have_content('Marriage created.')
          end

          expect(user.reload.spouse).to eq(proposee)
          expect(proposee.reload.spouse).to eq(user)
        end
      end
    end

    context 'when the user is in a marriage with a partner', :rack_test_driver do
      before { expect(user.marriage.partners.compact.size).to eq(2) }

      let(:spouse) { user.spouse }

      it 'redirects the user to the check-ins page with a flash message about already being married' do
        visit_new_marriage_path

        expect(page).to have_flash_message('You are already married', type: :alert)
        expect(page).to have_current_path(check_ins_path)
      end
    end
  end
end
