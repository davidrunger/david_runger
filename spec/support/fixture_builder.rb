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

    # admin users
    name(:admin_user, create(:admin_user, email: 'davidjrunger@gmail.com'))

    # groceries
    store = name(:store, create(:store, user: user)).first
    name(:item, create(:item, store: store))

    # number logs
    number_log = name(:number_log, create(:log, user: user, data_type: 'number')).first
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
        user: user,
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
    name(:request, create(:request))

    # sms records
    name(:sms_record, create(:sms_record, user: user))

    # workouts
    name(:workout, create(:workout, user: user))

    # auth tokens
    create(:auth_token, user: user)

    # IP blocks
    name(:ip_block, create(:ip_block))

    # quizzes
    quiz = create(:quiz, owner: admin)

    # quiz participations
    create(:quiz_participation, quiz: quiz, participant: user)

    # quiz questions
    quiz_question_1 = create(:quiz_question, quiz: quiz)
    quiz_question_2 = create(:quiz_question, quiz: quiz)

    # quiz question answers
    [true, false, false].shuffle.each do |is_correct|
      create(:quiz_question_answer, question: quiz_question_1, is_correct: is_correct)
    end
    [true, false].shuffle.each do |is_correct|
      create(:quiz_question_answer, question: quiz_question_2, is_correct: is_correct)
    end
  end
end
