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
    column(:name) { |quiz| link_to(quiz.name, admin_quiz_path(quiz.id)) }
    column :owner
    column :status
    column :created_at
    column :updated_at
    column :current_question_number
    actions
  end

  show do
    attributes_table do
      row :name
      row :owner
      row :status
      row :current_question_number
      row :created_at
      row :updated_at
    end

    panel 'Questions' do
      table_for quiz.questions.order(:created_at) do
        column(:id) { |question| link_to(question.id, admin_quiz_question_path(question.id)) }
        column :content
        column :status
        column do |question|
          span link_to('View', admin_quiz_question_path(question.id))
          span link_to('Edit', edit_admin_quiz_question_path(question.id))
          span link_to('Delete', admin_quiz_question_path(question.id), method: :delete)
        end
      end
    end

    active_admin_comments
  end
end
