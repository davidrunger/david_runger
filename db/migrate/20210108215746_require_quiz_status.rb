# frozen_string_literal: true

class RequireQuizStatus < ActiveRecord::Migration[6.1]
  def change
    change_column :quizzes, :status, :string, default: 'unstarted', null: false
  end
end
