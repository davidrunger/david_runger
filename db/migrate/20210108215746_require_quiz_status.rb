# frozen_string_literal: true

class RequireQuizStatus < ActiveRecord::Migration[6.1]
  def change
    # rubocop:disable Rails/ReversibleMigration
    change_column :quizzes, :status, :string, default: 'unstarted', null: false
    # rubocop:enable Rails/ReversibleMigration
  end
end
