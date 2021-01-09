# frozen_string_literal: true

class QuizQuestions::CreateFromList < ApplicationAction
  CORRECT_ANSWER_PREFIX = '- '

  requires :quiz, Shaped::Shape(Quiz)
  requires :questions_list, Shaped::Shape(String)

  def execute
    question_and_answer_text_chunks.each do |question_and_answer_text_chunk|
      create_models_from_text!(question_and_answer_text_chunk)
    end
  end

  private

  def question_and_answer_text_chunks
    questions_list.delete("\r").strip.split(/\n{2,}/)
  end

  def create_models_from_text!(question_and_answer_text_chunk)
    question_text, *answer_texts = question_and_answer_text_chunk.split("\n")

    question = quiz.questions.create!(content: question_text.strip)

    answer_texts.each do |answer_text|
      create_answer_from_text!(answer_text: answer_text, question: question)
    end
  end

  def create_answer_from_text!(answer_text:, question:)
    if answer_text.start_with?(CORRECT_ANSWER_PREFIX)
      is_correct = true
      answer_text = answer_text.delete_prefix(CORRECT_ANSWER_PREFIX)
    else
      is_correct = false
    end
    question.answers.create!(is_correct: is_correct, content: answer_text.strip)
  end
end
