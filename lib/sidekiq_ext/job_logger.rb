# frozen_string_literal: true

require 'sidekiq/job_logger'

module SidekiqExt ; end

class SidekiqExt::JobLogger < ::Sidekiq::JobLogger
  def job_hash_context(job_hash)
    {
      bid: job_hash['bid'],
      jid: job_hash['jid'],
      tags: job_hash['tags'],
      queue: job_hash['queue'],
      # If we're using a wrapper class, like ActiveJob, use the "wrapped"
      # attribute to expose the underlying thing.
      class: job_hash['wrapped'] || job_hash['class'],
      args: job_hash['args'].to_s,
    }.compact
  end
end
