# frozen_string_literal: true

# rubocop:disable Style/MixinUsage
include FactoryBot::Syntax::Methods
# rubocop:enable Style/MixinUsage

FixtureBuilder.configure do |fbuilder|
  # rebuild fixtures automatically when these files change:
  fbuilder.files_to_check += Dir[
    'spec/factories/*.rb',
    'spec/fixtures.rb',
    'spec/support/fixture_builder.rb',
  ]

  fbuilder.factory do
    # users
    user = name(:user, create(:user)).first
    admin = name(:admin, create(:user, :admin)).first
    name(:single_user, create(:user))

    # admin users
    name(:admin_user, create(:admin_user, email: 'davidjrunger@gmail.com'))

    # groceries
    store = name(:store, create(:store, user:)).first
    name(:item, create(:item, :needed, store:))
    create(:item, :unneeded, store:)

    # number logs
    number_log = name(:number_log, create(:log, user:, data_type: 'number')).first
    number_log.log_entries.create!(
      log: number_log,
      data: 102,
      note: 'I am glad it is an even number',
    )
    create(
      :log,
      user: admin,
      name: 'Chinups',
      data_label: '# of chinups',
      data_type: 'counter',
      description: nil,
    )

    # text logs
    text_log = name(
      :text_log,
      create(
        :log,
        user:,
        name: 'Dream Journal',
        data_type: 'text',
        data_label: 'Dream content',
        description: nil,
      ),
    ).first
    text_log.log_entries.create!(log: text_log, data: 'Had a cool dream!')

    # log shares
    name(:log_share, create(:log_share, log: number_log))

    # requests
    request = name(:request, create(:request)).first

    # workouts
    name(:workout, create(:workout, user:))

    # auth tokens
    create(:auth_token, user:)

    # IP blocks
    name(:ip_block, create(:ip_block))

    # banned path fragments
    create(:banned_path_fragment, value: 'wp')
    create(:banned_path_fragment, value: 'wordpress')

    # quizzes
    quiz = create(:quiz, owner: admin)

    # quiz participations
    participation = create(:quiz_participation, quiz:, participant: user)
    participation_2 = create(:quiz_participation, quiz:, participant: admin)

    # quiz questions
    quiz_question_1 = create(:quiz_question, quiz:)
    quiz_question_2 = create(:quiz_question, quiz:)

    # quiz question answers
    [true, false, false].shuffle.each do |is_correct|
      create(:quiz_question_answer, question: quiz_question_1, is_correct:)
    end
    [true, false].shuffle.each do |is_correct|
      create(:quiz_question_answer, question: quiz_question_2, is_correct:)
    end

    # quiz question answer selections
    answer = quiz.question_answers.first!
    answer_2 = quiz.question_answers.second!
    create(:quiz_question_answer_selection, answer:, participation:)
    create(:quiz_question_answer_selection, answer: answer_2, participation: participation_2)

    # marriages
    marriage = create(:marriage, partner_1: user, partner_2: admin)

    # emotional needs
    emotional_need = create(:emotional_need, marriage:)

    # check-ins
    check_in = create(:check_in, marriage:)

    # need satisfaction ratings
    create(:need_satisfaction_rating, emotional_need:, check_in:, user:, score: 3)
    create(:need_satisfaction_rating, emotional_need:, check_in:, user: admin, score: -3)

    # csp reports
    name(:csp_report, create(:csp_report, ip: request.ip))

    # Deploys
    name(:deploy, create(:deploy))
  end
end
