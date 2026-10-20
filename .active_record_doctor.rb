ActiveRecordDoctor.configure do
  global :ignore_models,
    [
      /^ActionMailbox::/,
      'ActiveAdmin::Comment',
      /^ActiveStorage::/,
      /^Blazer::/,
      'PaperTrail::Version',
      /^PgHero::/,
    ]

  global :ignore_tables,
    [
      /^action_mailbox_/,
      'action_text_rich_texts',
      'active_admin_comments',
      /^active_storage_/,
      'ar_internal_metadata',
      /^blazer_/,
      /^pghero_/,
      'schema_migrations',
      'versions',
    ]

  # Index detectors do not handle all of the project's composite and expression
  # indexes, which leads to false positives.
  detector :extraneous_indexes, enabled: false
  detector :missing_unique_indexes, enabled: false
  detector :unindexed_foreign_keys, enabled: false

  # Keep callbacks when associated records are deleted.
  detector :incorrect_dependent_option, enabled: false
end
