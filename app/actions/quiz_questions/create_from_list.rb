class QuizQuestions::CreateFromList < ApplicationAction
  prepend Memoization

  class InvalidAnswers < StandardError ; end

  CORRECT_ANSWER_PREFIX = /\A\s*-\s*/
  MAX_QUESTIONS = 500
  MAX_ANSWERS = MAX_QUESTIONS * 10

  requires :quiz, Quiz
  requires :questions_list, String

  fails_with :invalid_answers

  def execute
    validate_upload_size!(question_and_answer_text_chunks)

    Quiz.transaction do
      question_and_answer_text_chunks.each do |question_and_answer_text_chunk|
        create_models_from_text!(question_and_answer_text_chunk)
      end

      verify_answers!
    end
  rescue InvalidAnswers => error
    result.invalid_answers!(error.message)
  end

  private

  memoize \
  def question_and_answer_text_chunks
    questions_list.delete("\r").strip.split(/\n{2,}/, MAX_QUESTIONS + 1)
  end

  def validate_upload_size!(question_and_answer_text_chunks)
    if question_and_answer_text_chunks.size > MAX_QUESTIONS
      raise(InvalidAnswers, "Uploads may contain no more than #{MAX_QUESTIONS} questions.")
    end

    answer_count = question_and_answer_text_chunks.sum { |chunk| chunk.count("\n") }
    if answer_count > MAX_ANSWERS
      raise(InvalidAnswers, "Uploads may contain no more than #{MAX_ANSWERS} answers.")
    end
  end

  def create_models_from_text!(question_and_answer_text_chunk)
    question_text, *answer_texts = question_and_answer_text_chunk.split("\n")

    question = quiz.questions.create!(content: question_text.strip)

    answer_texts.each do |answer_text|
      create_answer_from_text!(answer_text:, question:)
    end
  end

  def create_answer_from_text!(answer_text:, question:)
    if answer_text.match?(CORRECT_ANSWER_PREFIX)
      is_correct = true
      answer_text = answer_text.sub(CORRECT_ANSWER_PREFIX, '')
    else
      is_correct = false
    end
    question.answers.create!(is_correct:, content: answer_text.strip)
  end

  def verify_answers!
    quiz.questions.includes(:answers).find_each do |question|
      content = question.content
      answers = question.answers

      if answers.size < 2
        raise(InvalidAnswers, "Too few answers for question '#{content}'!")
      end

      if answers.count(&:is_correct?) != 1
        raise(InvalidAnswers, "Wrong number of correct answers for question '#{content}'!")
      end
    end
  end
end
