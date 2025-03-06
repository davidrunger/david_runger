class SetUser1Email < Datamigration::Base
  def run
    within_transaction(rollback: true) do
      user = User.find(1)

      log("Email before: #{user.email} .")

      user.update!(email: 'davidjrunger@gmail.com')

      log("Email after: #{user.email} .")
    end
  end
end

Datamigration::Runner.new(SetUser1Email).run
