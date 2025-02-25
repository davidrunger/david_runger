class Api::CommentsController < Api::BaseController
  # Even logged-out users should be able to view comments.
  skip_before_action :authenticate_user!, only: %i[index]

  def create
    authorize(Comment)

    comment =
      Comments::Create.run!(
        user: current_user,
        params: comment_params.merge(
          path: referrer_without_query_params,
        ),
      ).comment

    render_schema_json(comment)
  end

  def destroy
    comment = current_user.comments.find(params[:id])

    authorize(comment)

    comment.destroy!

    head :ok
  end

  def index
    authorize(Comment)

    comments =
      Comment.
        where(path: referrer_without_query_params).
        includes(:user)

    render_schema_json(comments)
  end

  def update
    comment = current_user.comments.find(params[:id])

    authorize(comment)

    comment.update!(comment_params)

    render_schema_json(comment)
  end

  private

  def comment_params
    params.expect(comment: %i[content parent_id])
  end

  def referrer_without_query_params
    Addressable::URI.parse(request.referer).path
  end
end
