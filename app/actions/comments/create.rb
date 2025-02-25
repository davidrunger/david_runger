class Comments::Create < ApplicationAction
  requires :user, User
  requires :params, ActionController::Parameters

  returns :comment, Comment

  def execute
    comment = user.comments.create!(params)

    result.comment = comment

    AdminMailer.comment_created(comment.id).deliver_later

    if comment.parent && (comment.parent.user_id != comment.user_id)
      CommentMailer.reply_created(comment.parent_id, comment.id).deliver_later
    end
  end
end
