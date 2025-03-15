class PgHero::CleanQueryStats
  prepend ApplicationWorker

  unique_while_executing!

  def perform
    PgHero.clean_query_stats
  end
end
