RSpec.describe 'Blog' do
  context 'when a blog article with a #comments div exists in the blog/ directory' do
    before do
      FileUtils.mkdir_p('blog')
      File.write(blog_file_path, <<~HTML)
        <!doctype html>
        <html lang="en">
          <head>
            <meta charset="utf-8" />
            <title>Enforce Git hooks</title>
          </head>
          <body class="post">
            <main class="px-3">
              <article>
                <hgroup>
                  <h1>#{h1_text}</h1>
                </hgroup>
                <p>
                  Git has a cool feature called
                  <a href="https://githooks.com/">Git hooks</a>.
                </p>
              </article>
              <div id="comments"></div>
            </main>
            <footer>
              <div>© 2025 by <a href="https://davidrunger.com/">David Runger</a></div>
            </footer>
          </body>
        </html>
      HTML
    end

    after do
      FileUtils.rm_f(blog_file_path)
    end

    let(:blog_file_path) { "blog/#{blog_article_slug}.html" }
    let(:blog_url_path) { "/blog/#{blog_article_slug}" }
    let(:blog_article_slug) { 'something-i-learned' }
    let(:h1_text) { 'Enforce Git hooks in a Rails initializer' }

    context 'when OmniAuth test mode is enabled and OmniAuth is mocked for an email not yet registered as a User' do
      before do
        expect(OmniAuth.config.test_mode).to eq(true)
        MockOmniAuth.google_oauth2(email: new_user_email)
      end

      let(:new_user_email) { "#{SecureRandom.alphanumeric(5)}-#{Faker::Internet.email}" }
      let(:existing_user) { users(:user) }
      let(:existing_user_email) { existing_user.email }

      context 'when the replying user is at least 1 minute old' do
        before { existing_user.update!(created_at: 1.minute.ago) }

        it 'shows the blog article content and allows making comments, replying to comments, editing comments, and deleting comments' do
          visit blog_url_path

          expect(page).to have_text(h1_text)

          click_on('Sign in / sign up')
          click_on('Log in with Google')
          fill_in('Public display name', with: 'Sue Salamander')
          click_on('Submit')

          comment_text = 'I have something to say!'
          fill_in('Write a comment...', with: comment_text)
          click_on('Post')

          expect(page).to have_css('.comment', text: comment_text)

          Capybara.using_session('replier') do
            MockOmniAuth.google_oauth2(email: existing_user_email)

            visit blog_url_path

            click_on('Sign in / sign up')
            click_on('Log in with Google')

            click_on('Reply')
            reply_text = 'I have something to say in reply!'
            find_all(:fillable_field, 'Write a comment...')[1].send_keys(reply_text)

            with_inline_sidekiq do
              num_emails_before = ActionMailer::Base.deliveries.size
              click_on('Reply')
              # Wait for two emails: one to an admin and one to the user being replied to.
              wait_for { ActionMailer::Base.deliveries.size }.to eq(num_emails_before + 2)
            end

            expect(page).to have_css('.comment', text: reply_text)

            open_email(new_user_email.downcase)

            expect(current_email).to be_present
            expect(current_email).to have_text(<<~EMAIL.squish)
              User #{existing_user.id} has replied to a comment that you made at
              https://davidrunger.com/blog/something-i-learned .
              Comment content
              I have something to say in reply!
            EMAIL

            click_on('Edit')
            additional_text = ' Additionally!'
            find_all(:fillable_field, 'Write a comment...')[1].send_keys(additional_text)
            click_on('Update')

            expect(page).to have_css('.comment', text: "#{reply_text}#{additional_text}")
          end

          # Reload the page to load the reply comment.
          visit blog_url_path

          expect(comment_count).to eq(2)

          click_on('Delete')

          # Because the comment has at least one reply, it is anonymized, rather than fully deleted.
          expect(comment_count).to eq(2)
          expect(page).to have_text('[deleted]')

          Capybara.using_session('replier') do
            visit blog_url_path
            click_on('Delete')

            # Because the reply has no replies of its own, clicking "Delete" fully deletes it.
            expect(comment_count).to eq(1)
          end
        end
      end
    end
  end

  def comment_count
    page.find_all('.comment').size
  end
end
