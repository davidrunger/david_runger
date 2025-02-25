class CommentMailer < ApplicationMailer
  def reply_created(parent_comment_id, reply_comment_id)
    parent_comment = Comment.find(parent_comment_id)
    @reply_comment = Comment.find(reply_comment_id)

    mail(
      to: parent_comment.user.email,
      subject: "Someone has replied to your comment at #{parent_comment.path}",
    )
  end
end
