RSpec.describe Comments::Create, queue_adapter: :test do
  subject(:run_action) do
    described_class.run!(user:, params:)
  end

  let(:user) { users(:user) }
  let(:parent_user) { users(:married_user) }
  let!(:parent) { create(:comment, user: parent_user) }
  let(:params) do
    ActionController::Parameters.
      new(
        content: 'A thoughtful reply',
        parent_id: parent.id,
        path: parent.path,
      ).
      permit(:content, :parent_id, :path)
  end

  it 'creates the comment and sends the permitted notifications' do
    expect { run_action }.
      to have_enqueued_mail(AdminMailer, :comment_created).
      and have_enqueued_mail(CommentMailer, :reply_created)

    comment = run_action.comment
    expect(comment).to be_persisted
  end

  context 'when the reply email delivery limit is reached' do
    before do
      Email::UserGeneratedDeliveryLimiter::ACTOR_RECIPIENT_15_MINUTES_LIMIT.maximum.times do
        Email::UserGeneratedDeliveryLimiter.reserve(
          actor: user,
          recipient_email: parent_user.email,
          category: :comment_reply,
        )
      end
    end

    it 'retains the comment and sends only the administrator notification' do
      expect { run_action }.
        to have_enqueued_mail(AdminMailer, :comment_created).
        and have_enqueued_mail(CommentMailer, :reply_created).exactly(0).times

      expect(run_action.comment).to be_persisted
    end
  end

  context 'when the author replies to their own comment' do
    let(:parent_user) { user }

    it 'does not send a reply email' do
      expect { run_action }.
        to have_enqueued_mail(AdminMailer, :comment_created).
        and have_enqueued_mail(CommentMailer, :reply_created).exactly(0).times

      expect(run_action.comment).to be_persisted
    end
  end

  context 'when the parent comment no longer has an author' do
    let(:parent) { create(:comment, user: nil) }

    it 'does not send a reply email' do
      expect { run_action }.
        to have_enqueued_mail(AdminMailer, :comment_created).
        and have_enqueued_mail(CommentMailer, :reply_created).exactly(0).times

      expect(run_action.comment).to be_persisted
    end
  end
end
