# frozen_string_literal: true

RSpec.describe 'Check-Ins app' do
  context 'when user is signed in' do
    before { sign_in(user) }

    let(:user) { users(:user) }
    let(:marriage) { user.marriage }

    context 'when the user is not yet in a marriage with a partner' do
      before do
        expect(marriage.partner_1).to eq(user)
        marriage.update!(partner_2: nil)
      end

      let(:proposee) { User.where.not(id: user).first! }

      context 'when a jwt_secret credential is available' do
        before do
          expect(Rails.application.credentials).
            to receive(:jwt_secret!).
            at_least(:once).
            and_return('xyz248')
        end

        it 'allows inviting spouse, adding emotional needs, and accepting proposal' do
          visit check_ins_path

          expect(page).to have_text('Enter the email of your spouse')

          fill_in('spouse_email', with: proposee.email)
          Sidekiq::Testing.inline! do # enable inline Sidekiq to send email
            activate_feature!(:disable_fetch_ip_info_for_request_worker)
            click_button('Submit')
          end

          expect(page).to have_text('Invitation sent.')

          # add an emotional need
          click_link('Click here')
          new_need_name = Faker::Emotion.unique.noun.capitalize
          new_need_description = Faker::Company.unique.bs.capitalize
          fill_in('Name', with: new_need_name)
          fill_in('Description', with: new_need_description)
          click_button('Create Emotional need')

          expect(page).to have_text("#{new_need_name} (#{new_need_description})")

          # log in proposee and accept the proposal
          Capybara.using_session('proposee') do
            wait_for do
              sign_in(proposee)
              visit(groceries_path)
              page.has_text?(proposee.email)
            end.to eq(true)

            open_email(proposee.email)
            current_email.click_link('accept')
            expect(page).to have_content('Marriage created.')
          end
        end
      end
    end

    context 'when the user is in a marriage with a partner' do
      before { expect(user.marriage.partners.compact.size).to eq(2) }

      let(:spouse) { marriage.partners.where.not(id: user).first! }

      context 'when the marriage has emotional need(s)' do
        before { expect(marriage.emotional_needs).to exist }

        let(:first_emotional_need) { marriage.emotional_needs.first! }

        it "allows creating a check-in, rating need fulfillment, viewing partner's ratings, etc" do
          visit check_ins_path

          expect(page).to have_button('Create a new check-in')
          expect(page).to have_text('Previous check-ins')
          expect(page).to have_text('Manage emotional needs')

          click_button('Create a new check-in')

          check_in = CheckIn.order(:created_at).last!
          expect(page).to have_current_path(check_in_path(check_in))

          fill_in_emotional_needs_ratings(rating: 2)
          click_button('Update Check-in')
          wait_for do
            CheckIn.order(:created_at).last!.
              need_satisfaction_ratings.
              exists?(user:, score: nil)
          end.to eq(false)
          sleep(0.2) # this seems to be needed to ensure the rating update transaction is committed

          # other partner fills in ratings
          Capybara.using_session('spouse') do
            wait_for do
              sign_in(spouse)
              visit(check_in_path(check_in))
              page.has_text?('Their answers [hidden until you submit your answers]')
            end.to eq(true)
            fill_in_emotional_needs_ratings(rating: -2)
            click_button('Update Check-in')
            expect(page).to have_text("Their answers #{first_emotional_need.name}: 2")
          end

          click_button('Update Check-in') # refresh the page by clicking button
          expect(page).to have_text("Their answers #{first_emotional_need.name}: -2")
        end

        def fill_in_emotional_needs_ratings(rating:)
          marriage.emotional_needs.each do |emotional_need|
            page.find('strong', text: emotional_need.name).
              find(:xpath, '..'). # parent
              find('button.need_satisfaction_rating', text: /\A#{rating}\z/).
              click
          end
        end
      end
    end
  end
end
