class Comments::Create < ApplicationAction
  requires :user, User
  requires :params, ActionController::Parameters

  returns :comment, Comment

  def execute
    comment = user.comments.create!(params)

    result.comment = comment

    AdminMailer.comment_created(comment.id).deliver_later

    parent_user = comment.parent&.user

    if parent_user && (parent_user != user)
      delivery_limit =
        Email::UserGeneratedDeliveryLimiter.reserve(
          actor: user,
          recipient_email: parent_user.email,
          category: :comment_reply,
        )

      if delivery_limit.permitted?
        CommentMailer.reply_created(comment.parent_id, comment.id).deliver_later
      end
    end
  end
end
