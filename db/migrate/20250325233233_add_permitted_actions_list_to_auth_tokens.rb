class AddPermittedActionsListToAuthTokens < ActiveRecord::Migration[8.0]
  def change
    add_column(
      :auth_tokens,
      :permitted_actions_list,
      :text,
      comment: <<~COMMENT.squish,
        A comma- and/or whitespace-separated list of controller actions (in the
        form `api/csp_results#create`) for which the auth token may be used
        as an authorization mechanism. Note: A blank list means that the
        AuthToken is valid for all controller actions.
      COMMENT
    )
  end
end
