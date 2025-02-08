ActiveAdmin.register(Deploy) do
  decorate_with DeployDecorator

  controller do
    def scoped_collection
      Deploy.select(<<~SQL.squish)
        deploys.*,
        LAG(deploys.git_sha) OVER (ORDER BY deploys.created_at) AS previous_git_sha
      SQL
    end
  end

  index do
    id_column
    column('Git SHA') { it.github_commit_link }
    column('Diff') { it.github_diff_link }
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :id
      row('Git SHA') { it.github_commit_link }
      row('Diff') { it.github_diff_link }
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end
end
