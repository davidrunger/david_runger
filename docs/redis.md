# Redis databases

The application uses Redis logical databases on `REDIS_URL`. Redis provides
databases `0` through `15`; these databases share the same Redis server and
resources, but their keys and `FLUSHDB` operations are separate.

## Development

| Database | Uses |
| --- | --- |
| `0` | Direct application Redis through `$redis_pool`, Flipper, and the email-quota limiter. Action Cable also uses this database when `REDIS_URL` has no database path. |
| `1` | Sidekiq by default. `SIDEKIQ_REDIS_DATABASE_NUMBER` can override this outside test. |
| `2` | `Runger::RungerConfig`, through `$runger_redis` in `config/initializers/z.rb` when the application is not running in Docker. |
| `3` | The Pallets test runner. The gitignored `personal/guardfiles/run_sidekiq.rb` also uses this database. Do not run that Guard runner and Pallets concurrently; the test command and Guard runner flush database `3`. |

The Redis cache uses `REDIS_CACHE_URL`, so its database depends on that URL
and is not part of this fixed mapping.

## Test and CI

`RedisOptions` uses `DB_SUFFIX` to keep each test group in its own pair of
databases. The regular application Redis, Flipper, and email-quota state use
the general test database; Sidekiq uses the corresponding Sidekiq database.

| `DB_SUFFIX` | General test database | Sidekiq database |
| --- | ---: | ---: |
| `_unit` | `4` | `10` |
| `_api` | `5` | `11` |
| `_html` | `6` | `12` |
| `_feature_a` | `7` | `13` |
| `_feature_b` | `8` | `14` |
| `_feature_c` | `9` | `15` |

In Rails test, `RedisOptions` derives the database from `DB_SUFFIX`, even if
the caller passes an explicit `db:` value. Database `3` is reserved for the
Pallets backend and is outside this per-test-group mapping.

Action Cable uses database `0` in test, but its `channel_prefix` includes
`DB_SUFFIX`, which keeps channel names separate from the test groups above.

The non-Docker `config/initializers/z.rb` still uses database `2` directly
for `Runger::RungerConfig`; it is not part of the `DB_SUFFIX` mapping.
