class DeployDecorator < Draper::Decorator
  delegate_all

  def github_commit_link
    h.link_to(
      git_sha,
      "https://github.com/davidrunger/david_runger/commit/#{git_sha}",
    )
  end

  def github_diff_link
    if previous_git_sha
      # We expect to enter this branch in the index view.
      github_compare_link("#{deploy.previous_git_sha.first(8)}...#{deploy.git_sha.first(8)}")
    elsif (
      previous_deploy =
        Deploy.where(deploys: { created_at: ...created_at }).reorder(:created_at).last
    )
      # We expect to enter this branch in the show view.
      github_compare_link("#{previous_deploy.git_sha.first(8)}...#{deploy.git_sha.first(8)}")
    else
      # This is expected only for the earliest deploy.
      'N/A'
    end
  end

  def to_s
    "Deploy of #{git_sha.first(8)}"
  end

  private

  def github_compare_link(diff_range)
    h.link_to(
      diff_range,
      "https://github.com/davidrunger/david_runger/compare/#{diff_range}",
    )
  end
end
