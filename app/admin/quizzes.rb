# frozen_string_literal: true

ActiveAdmin.register(Quiz) do
  decorate_with Admin::QuizDecorator
  includes :owner

  config.batch_actions = false

  controller do
    def find_resource
      collection = scoped_collection
      if params[:action] == 'destroy'
        collection =
          collection.includes(
            participations: :quiz_question_answer_selections,
            questions: { answers: :selections },
          )
      end
      collection.find(params[:id])
    end
  end

  index do
    id_column
    column :name
    column :owner
    column :status
    column :created_at
    column :updated_at
    column :current_question_number
    actions
  end
end
