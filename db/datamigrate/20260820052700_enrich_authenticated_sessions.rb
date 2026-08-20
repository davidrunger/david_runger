# Run locally:
#   bin/rails runner db/datamigrate/20260820052700_enrich_authenticated_sessions.rb
#
# Run in production after this datamigration deploys:
#   bin/run-datamigration db/datamigrate/20260820052700_enrich_authenticated_sessions.rb

class EnrichAuthenticatedSessions < Datamigration::Base
  include SpacedLaunching

  def run
    authenticated_sessions = AuthenticatedSession.where(isp: nil).or(
      AuthenticatedSession.where(location: nil),
    )

    log("Enqueueing IP info fetches for #{authenticated_sessions.size} AuthenticatedSessions.")

    launch_with_spacing(
      worker: FetchIpInfoForRecord,
      arguments_list: authenticated_sessions.find_each.map { [it.class.name, it.id] },
      spacing_seconds: 5,
    )
  end
end

Datamigration::Runner.new(EnrichAuthenticatedSessions).run
