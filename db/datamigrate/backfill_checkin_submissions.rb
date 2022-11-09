# frozen_string_literal: true

class BackfillCheckinSubmissions
  Helper = Struct.new(:current_user)

  def run
    puts("Before #{__FILE__.delete_prefix(Rails.root.join('/').to_s)}")
    puts("CheckIn.count: #{CheckIn.count}")
    puts("CheckInSubmission.count: #{CheckInSubmission.count}")

    CheckIn.order(:created_at).find_each do |check_in|
      marriage = check_in.marriage
      [marriage.partner_1, marriage.partner_2].each do |user|
        decorated_check_in = check_in.decorate

        decorated_check_in.singleton_class.class_eval do
          define_method(:h) do
            Helper.new(user)
          end
        end

        next unless decorated_check_in.all_ratings_scored_by_self?

        CheckInSubmission.create!(
          check_in:,
          user:,
        )
      end
    end

    puts("After #{__FILE__.delete_prefix(Rails.root.join('/').to_s)}")
    puts("CheckIn.count: #{CheckIn.count}")
    puts("CheckInSubmission.count: #{CheckInSubmission.count}")
  end
end
