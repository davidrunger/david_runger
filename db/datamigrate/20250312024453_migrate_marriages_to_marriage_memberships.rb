class MigrateMarriagesToMarriageMemberships < Datamigration::Base
  def run
    within_transaction do
      Marriage.find_each do |marriage|
        if (partner_1 = marriage.partner_1)
          log("Adding #{partner_1.email} to #{marriage.class_id_string}.")
          marriage.memberships.create!(
            user: partner_1,
            created_at: marriage.created_at,
          )
        end

        if (partner_2 = marriage.partner_2)
          log("Adding #{partner_2.email} to #{marriage.class_id_string}.")
          marriage.memberships.create!(
            user: partner_2,
            # Partner 2 might not actually have joined at the marriage's
            # updated_at timestamp, but it's our best available guess, and it
            # is probably usually accurate.
            created_at: marriage.updated_at,
          )
        end
      end
    end
  end
end

Datamigration::Runner.new(MigrateMarriagesToMarriageMemberships).run
