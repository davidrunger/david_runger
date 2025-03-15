class PgHero::CaptureSpaceStats
  prepend ApplicationWorker

  unique_while_executing!

  def perform
    PgHero.capture_space_stats
  end
end
