PaperTrail.config.enabled = true
PaperTrail.config.has_paper_trail_defaults = {
  # Omit `create` events.
  on: %i[destroy touch update],
}
