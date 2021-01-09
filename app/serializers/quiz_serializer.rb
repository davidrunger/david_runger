# frozen_string_literal: true

# == Schema Information
#
# Table name: quizzes
#
#  created_at              :datetime         not null
#  current_question_number :integer          default(1), not null
#  id                      :bigint           not null, primary key
#  name                    :string
#  owner_id                :bigint           not null
#  status                  :string           default("unstarted"), not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_quizzes_on_owner_id  (owner_id)
#
class QuizSerializer < ActiveModel::Serializer
  attributes :hashid
end
