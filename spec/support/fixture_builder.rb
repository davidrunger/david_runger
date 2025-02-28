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
    married_user = name(:married_user, create(:user)).first
    name(:single_user, create(:user))

    # AdminUsers
    admin_user = name(:admin_user, create(:admin_user, email: 'davidjrunger@gmail.com')).first

    # groceries
    store = name(:store, create(:store, user:, name: 'Target')).first
    name(:item, create(:item, :needed, store:, name: 'olive oil', needed: 2))
    create(:item, :unneeded, store:, name: 'apples')

    # number logs
    number_log = name(:number_log, create(:log, user:, data_type: 'number')).first
    number_log.build_log_entry_with_datum(
      data: 102,
      note: 'I am glad it is an even number',
    ).save!

    create(
      :log,
      user: married_user,
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
    text_log.build_log_entry_with_datum(
      data: 'Had a cool dream!',
    ).save!

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
    quiz = create(:quiz, owner: married_user)

    # quiz participations
    participation = create(:quiz_participation, quiz:, participant: user)
    participation_2 = create(:quiz_participation, quiz:, participant: married_user)

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
    marriage = create(:marriage, partner_1: user, partner_2: married_user)

    # emotional needs
    emotional_need = create(:emotional_need, marriage:)

    # check-ins
    check_in = create(:check_in, marriage:)

    # need satisfaction ratings
    create(:need_satisfaction_rating, emotional_need:, check_in:, user:, score: 3)
    create(:need_satisfaction_rating, emotional_need:, check_in:, user: married_user, score: -3)

    # JSON Preferences
    create(:json_preference, :emoji_boosts, user:)

    # csp reports
    name(:csp_report, create(:csp_report, ip: request.ip))

    # Deploys
    name(:deploy, create(:deploy))
    create(:deploy)

    # Events
    name(:event, create(:event, user:, admin_user:))
    create(:event, user:, admin_user: nil)
    create(:event, user: married_user, admin_user:)
    create(:event, user: nil, admin_user: nil)

    # CiStepResults
    github_run_id = rand(1_000_000_000)
    github_run_attempt = 1
    create(:ci_step_result, :wall_clock_time, user:, github_run_id:, github_run_attempt:)
    create(:ci_step_result, :cpu_time, user:, github_run_id:, github_run_attempt:)
    create(:ci_step_result, :feature_tests, user:, github_run_id:, github_run_attempt:)
    create(:ci_step_result, :unit_tests, user:, github_run_id:, github_run_attempt:)
    other_github_run_id = github_run_id + rand(1_000_000_000)
    github_run_attempt = 1
    create(
      :ci_step_result,
      :wall_clock_time,
      user:,
      github_run_id: other_github_run_id,
      github_run_attempt:,
      branch: 'bugfix',
    )
    create(
      :ci_step_result,
      :cpu_time,
      user:,
      github_run_id: other_github_run_id,
      github_run_attempt:,
      branch: 'bugfix',
    )

    # Comments
    path = '/blog/using-crystal'
    top_level_comment = name(:top_level, create(:comment, user:, path:)).first
    name(:reply, create(:comment, user: married_user, path:, parent: top_level_comment))
  end
end
