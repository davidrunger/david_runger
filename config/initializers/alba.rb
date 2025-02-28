Alba.backend = :active_support

Alba.register_type(
  :iso8601z,
  converter: ->(time) { time.utc.iso8601(3) },
  auto_convert: true,
)
