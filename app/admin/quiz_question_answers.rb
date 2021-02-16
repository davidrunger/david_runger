# frozen_string_literal: true

ActiveAdmin.register(QuizQuestionAnswer) do
  menu false
  permit_params :content, :is_correct

  show do
    attributes_table do
      row(:question) do |answer|
        link_to(answer.question.content, admin_quiz_question_path(answer.question.id))
      end
      row :content
      row :is_correct
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input(:content)
      f.input(:is_correct)
    end
    f.actions
  end
end
