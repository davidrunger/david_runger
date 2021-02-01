# frozen_string_literal: true

def backfill_requests_bot_column
  Request.find_each do |request|
    user_agent = request.user_agent
    puts "Updating request #{request.id}. user_agent: #{user_agent}"
    bot_request = /bot=true/.match?(user_agent)
    user_agent.gsub!(/bot=(true|false) ?/, '')
    puts "Identified bot: #{bot_request}"
    puts "New user_agent string: #{user_agent}"
    request.update!(bot: bot_request, user_agent: user_agent)
    puts "Updated #{request.id} successfully"
    puts
  end

  puts 'Done.'
  puts "Total bot requests: #{Request.where(bot: true).count}"
  puts "Total non-bot requests: #{Request.where(bot: false).count}"
end
