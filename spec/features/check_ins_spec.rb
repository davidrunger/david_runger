RSpec.describe 'Check-Ins app' do
  context 'when user is signed in' do
    before { sign_in(user) }

    let(:user) { users(:user) }
    let(:marriage) { user.marriage }

    context 'when the user is not yet in a marriage' do
      before do
        marriage.destroy!
      end

      let(:proposee) { User.where.not(id: user).first! }

      it 'allows inviting spouse and accepting proposal, populates initial emotional needs, and allows adding an emotional need', :rack_test_driver do
        visit check_ins_path

        expect(page).to have_text('Enter the email of your spouse')

        fill_in('spouse_email', with: proposee.email)

        with_inline_sidekiq do
          activate_feature!(:disable_fetch_ip_info_for_request_worker)
          num_emails_before = ActionMailer::Base.deliveries.size
          click_on('Submit')
          wait_for { ActionMailer::Base.deliveries.size }.to eq(num_emails_before + 1)
        end

        expect(page).to have_flash_message('Invitation sent.')

        # View default emotional needs.
        click_on('Click here')
        Marriages::Create::DEFAULT_EMOTIONAL_NEEDS.each do |name, description|
          expect(page).to have_text(name)
          expect(page).to have_text(description)
        end

        # Add an emotional need.
        new_need_name = "#{Faker::Emotion.unique.noun.capitalize}-#{SecureRandom.alphanumeric(5)}"
        new_need_description = Faker::Company.unique.bs.capitalize
        fill_in('Name', with: new_need_name)
        fill_in('Description', with: new_need_description)
        click_on('Create Emotional need')

        expect(page).to have_text("#{new_need_name} (#{new_need_description})")

        # log in proposee and accept the proposal
        Capybara.using_session('proposee') do
          sign_in(proposee)
          visit(my_account_path)
          expect(page).to have_text(proposee.email)

          open_email(proposee.email)
          # rubocop:disable-next RungerStyle/ClickAmbiguously
          current_email.click_link('Click here', href: %r{/proposals/.+/confirm})
          expect(page).to have_text("#{user.email} wants you to join their marriage")
          expect(page).to have_button('Accept proposal')
          click_on('Accept proposal')
          expect(page).to have_text('Marriage created.')
        end

        expect(user.reload.spouse).to eq(proposee)
        expect(proposee.reload.spouse).to eq(user)
      end
    end

    context 'when the user is in a marriage with a partner' do
      before { expect(user.marriage.partners.compact.size).to eq(2) }

      let(:spouse) { marriage.partners.where.not(id: user).first! }

      context 'when the marriage has one emotional need' do
        before { expect(marriage.emotional_needs.size).to eq(1) }

        let(:first_emotional_need) { marriage.emotional_needs.first! }

        it "allows creating a check-in, rating need fulfillment, viewing partner's ratings, etc" do
          visit check_ins_path

          expect(page).to have_button('Create a new check-in')
          expect(page).to have_text('Previous check-ins')
          expect(page).to have_text('Manage emotional needs')

          click_on('Create a new check-in')

          # Wait for navigation to the show page of the new CheckIn.
          expect(page).to have_text(/Marriage Check-In #\d+/)

          check_in = CheckIn.order(:created_at).last!
          expect(page).to have_current_path(check_in_path(check_in))

          fill_in_emotional_needs_ratings(rating: 2)
          wait_for do
            check_in.need_satisfaction_ratings.where(user:).where.not(score: 2).exists?
          end.to eq(false)
          wait_for_network_idle
          reset_check_ins_channel_connection_marker
          click_on('Submit Check-in')
          wait_for { CheckInSubmission.exists?(user:, check_in:) }.to eq(true)
          wait_for_check_ins_channel_connection
          expect(page).to have_text("They didn't complete it yet.")

          # other partner fills in ratings
          Capybara.using_session('spouse') do
            sign_in(spouse)
            visit(check_in_path(check_in))
            expect(page).to have_text('Their answers [hidden until you submit your answers]')
            fill_in_emotional_needs_ratings(rating: -2)
            wait_for do
              check_in.need_satisfaction_ratings.where(user: spouse).where.not(score: -2).exists?
            end.to eq(false)
            wait_for_network_idle
            reset_check_ins_channel_connection_marker
            click_on('Submit Check-in')
            wait_for { CheckInSubmission.exists?(user: spouse, check_in:) }.to eq(true)
            wait_for_check_ins_channel_connection
            expect(page).to have_text(
              /Their answers #{first_emotional_need.name}igraph -3-2-101😀3/,
            )
          end

          expect(page).to have_text(
            /Their answers #{first_emotional_need.name}igraph -3😞-10123/,
          )

          # change rating
          fill_in_emotional_needs_ratings(rating: 1)
          wait_for do
            check_in.need_satisfaction_ratings.where(user:).where.not(score: 1).exists?
          end.to eq(false)

          # verify that partner sees the change
          Capybara.using_session('spouse') do
            expect(page).to have_text(
              /Their answers #{first_emotional_need.name}igraph -3-2-10🙂23/,
            )
          end

          # check for link(s) to graph of ratings of partner
          expect(page).to have_link(
            'graph',
            href: history_emotional_need_path(first_emotional_need, rated_user: 'partner'),
          )
          # view a graph
          first('a', text: 'graph').click
          # go back
          click_on('Go back')
          # check for link(s) to graph of partner's ratings of user
          expect(page).to have_link(
            'graph',
            href: history_emotional_need_path(first_emotional_need, rated_user: 'self'),
          )
        end

        def fill_in_emotional_needs_ratings(rating:)
          marriage.emotional_needs.each do |emotional_need|
            need_label_grandparent =
              page.
                first('strong', text: emotional_need.name).
                find(:xpath, '../..')

            expect(need_label_grandparent.find_all('button').size).to eq(7)

            # rubocop:disable-next Capybara/SpecificActions
            need_label_grandparent.
              find('button', text: /\A#{rating}\z/).
              click
          end
        end

        def reset_check_ins_channel_connection_marker
          page.execute_script('window.davidrunger.connectedToCheckInsChannel = false')
        end

        def wait_for_check_ins_channel_connection
          wait_for do
            page.evaluate_script('window.davidrunger?.connectedToCheckInsChannel')
          end.to eq(true)
        end
      end
    end
  end
end
