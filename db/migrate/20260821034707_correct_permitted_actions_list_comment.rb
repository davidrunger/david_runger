class CorrectPermittedActionsListComment < ActiveRecord::Migration[8.1]
  def change
    old_comment = <<~COMMENT.squish
      A comma- and/or whitespace-separated list of controller actions (in the
      form `api/csp_results#create`) for which the auth token may be used as an
      authorization mechanism. Note: A blank list means that the AuthToken is
      valid for all controller actions.
    COMMENT

    new_comment = <<~COMMENT.squish
      A comma- and/or whitespace-separated list of controller actions (in the
      form `api/csp_reports#create`) for which the auth token may be used as an
      authorization mechanism. Note: A blank list means that the AuthToken is
      valid for all controller actions.
    COMMENT

    change_column_comment(
      :auth_tokens,
      :permitted_actions_list,
      from: old_comment,
      to: new_comment,
    )
  end
end
