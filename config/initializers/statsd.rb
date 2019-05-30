# frozen_string_literal: true

StatsD.backend = StatsD::Instrument::Backends::UDPBackend.new('localhost:8125', :statsd)
