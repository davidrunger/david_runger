class QuizzesController < ApplicationController
  prepend Memoization
  include CspDisableable

  self.container_classes = %w[py-2 px-8]

  before_action :set_quiz, only: %i[respondents leaderboard progress]

  def index
    authorize(Quiz, :index?)
    @title = 'Quizzes'
    render :index
  end

  def show
    # don't use `policy_scope` here, because we want anyone to be able to view any quiz
    @quiz = Quiz.find_by_hashid!(params[:id]).decorate
    authorize(@quiz, :show?)

    @title = @quiz.name

    bootstrap(
      current_user: UserSerializer::Basic.new(current_user),
      quiz: QuizSerializer.new(@quiz),
    )

    render :show
  end

  def new
    authorize(Quiz, :new?)
    @title = 'New Quiz'
    @quiz = current_user.quizzes.build
    render :new
  end

  def create
    authorize(Quiz, :create?)
    quiz = current_user.quizzes.create!(quiz_params)
    redirect_to(quiz)
  end

  def update
    @quiz = policy_scope(Quiz).find_by_hashid!(params[:id])
    authorize(@quiz, :update?)
    Quizzes::Update.run!(quiz: @quiz, params: quiz_params)
    redirect_to(@quiz)
  end

  def destroy
    @quiz =
      policy_scope(Quiz).
        includes(
          participations: :quiz_question_answer_selections,
          questions: { answers: :selections },
        ).
        find_by_hashid!(params[:id])
    authorize(@quiz)

    @quiz.destroy!

    flash[:notice] = "Destroyed quiz '#{@quiz.name}'."

    redirect_to(quizzes_path)
  end

  def respondents
    authorize(@quiz, :show?)
    render partial: 'quiz_questions/respondents', locals: { question: @quiz.current_question }
  end

  def leaderboard
    authorize(@quiz, :show?)
    render partial: 'quiz/leaderboard', locals: { quiz: @quiz }
  end

  def progress
    authorize(@quiz, :show?)
    render partial: 'quiz/progress', locals: { quiz: @quiz }
  end

  private

  def set_quiz
    id_param = params[:id]

    quiz =
      Quiz.joins(:participations).
        merge(current_user.quiz_participations).
        find_by_hashid(id_param) ||
      current_user.quizzes.find_by_hashid(id_param)

    @quiz = quiz.presence!.decorate
  end

  def quiz_params
    params.expect(quiz: %i[current_question_number name status])
  end

  # rubocop:disable Style/MethodCallWithArgsParentheses
  helper_method \
  memoize \
  def current_user_participation
    @quiz.participations.find_by(participant_id: current_user)
  end
  # rubocop:enable Style/MethodCallWithArgsParentheses

  helper_method \
  def async_partial_delay_for_rails_env(delay_milliseconds)
    if Rails.env.test?
      0
    else
      delay_milliseconds
    end
  end
end
