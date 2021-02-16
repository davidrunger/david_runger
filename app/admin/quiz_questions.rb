# frozen_string_literal: true

ActiveAdmin.register(QuizQuestion) do
  menu false

  controller do
    def find_resource
      collection = scoped_collection
      if params[:action] == 'destroy'
        collection = collection.includes(answers: :selections)
      end
      collection.find(params[:id])
    end

    def destroy
      destroy! do |format|
        format.html { redirect_to(admin_quiz_path(resource.quiz.id)) }
      end
    end
  end

  show do
    attributes_table do
      row(:quiz) { |question| link_to(question.quiz.name, admin_quiz_path(question.quiz.id)) }
      row :content
      row :status
      row :created_at
      row :updated_at
    end

    panel 'Answers' do
      table_for quiz_question.answers.order(:created_at) do
        column(:id) { |answer| link_to(answer.id, admin_quiz_question_answer_path(answer.id)) }
        column :content
        column :is_correct
      end
    end

    active_admin_comments
  end
end
