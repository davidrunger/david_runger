# This is basically a noop datamigration that can be used to test datamigration
# infrastructure in production.

class DowncaseUser1Email < Datamigration::Base
  def run
    within_transaction do
      user = User.find(1)

      log("Email before: #{user.email} .")

      user.update!(email: user.email.downcase)

      log("Email after: #{user.email} .")
    end
  end
end

Datamigration::Runner.new(DowncaseUser1Email).run
