class DeployDecorator < Draper::Decorator
  delegate_all

  def github_commit_link
    h.link_to(
      git_sha,
      "https://github.com/davidrunger/david_runger/commit/#{git_sha}",
    )
  end

  def to_s
    "Deploy of #{git_sha.first(8)}"
  end
end
