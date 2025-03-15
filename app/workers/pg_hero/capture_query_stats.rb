class PgHero::CaptureQueryStats
  prepend ApplicationWorker

  unique_while_executing!

  def perform
    PgHero.capture_query_stats
  end
end
