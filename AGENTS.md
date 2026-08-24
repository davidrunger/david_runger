# Repository Guidelines

## Ruby conventions

- When a Ruby method's computed result is reused, prefer the repository's `Memoization` pattern over assigning a same-named local variable from `self`, such as `value = self.value`, solely to avoid recomputation. Add `prepend Memoization` to the class and decorate the method with `memoize \`.
- This repository intentionally loads standard-library dependencies used by Rails application code in `config/initializers/std_lib.rb` instead of requiring them in each consumer. This provides a Gemfile-like application contract: after the Rails environment initializes, the listed standard-library APIs are available throughout the application. It also prevents deleting one consumer, which happened to load a shared dependency, from breaking another consumer that relied on the same API.
- Add standard-library requires used by Rails-initialized code to `config/initializers/std_lib.rb` and remove redundant requires from individual consumers. Code that runs before or without Rails environment initialization must continue to require its dependencies locally.
- Do not use comments on individual entries in `config/initializers/std_lib.rb` as a consumer index. Such comments become incomplete or stale as usages change. Audit current usage by searching the repository, and reserve an entry-specific comment for non-obvious loading or compatibility requirements.

## Local tooling

- Prefer repository binstubs, such as `bin/rails` and `bin/rspec`, over commands that bypass them.
- Keep Spring enabled for local Rails commands because it substantially speeds up tests and other work. Disable Spring only for a concrete reason, not as a routine workaround.

## Routes

- Keep `root` at the top of `config/routes.rb`. All else being equal, group similar routes together. For example, keep relatively niche integration and infrastructure routes lower in the file, near related health-check, operational, or other specialized routes.

## Rollbar commit messages

- When the user provides a Rollbar item link that a commit is expected to fix, include both the Rollbar resolution marker and the item's full URL in the commit message body. Put each on its own line with a blank line between them, typically at the top or bottom of the body:

  ```text
  fixes rb#782

  https://app.rollbar.com/a/davidjrunger/fix/item/davidrunger/782
  ```

  Use the item number in the `fixes rb#<number>` marker so Rollbar automatically resolves the item when the commit is deployed. Include the full URL so reviewers and future readers can navigate to the item.

## Error reporting

- Report handled application conditions through `Rails.error.report` with an exception created by `Error.new`, rather than sending a bare string to Rollbar. `Error.new` supplies a backtrace so Rollbar identifies the source of the report. Do not also log the error at the call site: `ErrorSubscriber` logs every `Rails.error` report before sending it to Rollbar.

## Tests and coverage

- When adding a new model class, add at least one realistic baseline record to the FixtureBuilder setup unless fixtures are unsuitable for that model. Define a factory as needed to create the fixture. This lets specs reuse those records for faster setup and gives feature specs a more representative database state, increasing the chance that relevant data-shape bugs surface.
- Before running feature specs that exercise changed frontend assets, start the live Vite server with `./node_modules/.bin/vite --force` in a separate terminal and leave it running while iterating. This ensures that each feature-spec run uses the current source without rebuilding assets after every edit. When a task runner starts Vite as a managed background process instead, confirm that the server is ready before running specs and stop it when testing is complete.
- When investigating a flaky feature spec through repeated runs or otherwise planning to run one or more feature specs multiple times, first determine whether frontend assets will change. If they will not, compile the assets once before the first run and run the repetitions against the compiled output instead of starting the live Vite server. This avoids dev-server startup or optimization traffic interfering with timing-sensitive specs and generally makes repeated runs faster. Rebuild before any subsequent run after changing frontend assets.
- When running a live Vite server is impractical, run `RAILS_ENV=test bin/vite build` immediately before the relevant feature specs. Repeat the build after every frontend change; otherwise feature specs can silently exercise stale compiled assets.
- Run targeted specs with `bin/rspec path/to/spec.rb` while developing.
- Do not run multiple `bin/rspec` processes concurrently. They share the same test database and can interfere with one another; use the Pallets runner or another runner that provisions an isolated database for each process when parallel execution is needed.
- Run targeted linters on changed files when they provide useful feedback: `bin/rubocop` for Ruby; `pnpm exec oxlint` for JavaScript, TypeScript, and Vue; `pnpm exec stylelint` for CSS, SCSS, and Vue; `pnpm exec prettier` for Prettier-managed files; and `shellcheck` for shell scripts. Use appropriate check or autocorrect flags for the task, and inspect the diff after any autocorrection. Do not assume that personal helper commands such as `lint` are installed.
- Do not routinely run Vitest or TypeScript checks locally. Run them when the task particularly benefits from them; otherwise rely on CI.
- Do not run `bin/run-tests` locally by default. It is primarily a CI command, and CI may catch issues through checks that are intentionally not run during local development.
- When an expected asset-size change requires updating `Test::Tasks::RunFileSizeChecks::CONSTRAINTS`, round the reported size to the nearest whole KiB and set the constraint to a 10 KiB range centered on that value (rounded size minus 5 through rounded size plus 5).
- Maintain 100% line coverage for application Ruby code included in coverage, apart from lines that are explicitly ignored. Coverage may come from any combination of spec types; it does not need to come entirely from unit specs. Test-only Ruby code, including specs, support code, and CI/test-runner code under `lib/test/`, does not need 100% line coverage. Do not add or expand specs solely to cover test-only code.
- Do not run the entire test suite locally solely to confirm total coverage. CI performs the authoritative full-suite coverage check; Codecov also reports full-suite coverage.

## Test design

- Specs under `spec/controllers/api/` automatically receive `request_format: :json` through derived metadata in `spec/spec_helper.rb`. Do not repeat that metadata on individual API controller spec groups unless the spec intentionally needs different format behavior.
- When a spec needs a fixture record related to another fixture, obtain it through the relevant association rather than looking up a separately named fixture. Apply this when the relationship is part of the setup or behavior under test; when the spec only needs a record of a particular type, use a directly named fixture instead. This keeps required relationships explicit without making unrelated setup depend on them.

## Database migrations

- Generate schema migrations with `bin/rails generate migration NAME ...` instead of creating migration files manually. This preserves Rails generator conventions, including the correct migration class version.
- Generate datamigrations with the repository's custom generator:

  ```sh
  bin/rails generate datamigration NAME
  ```

- Prefer testing one-time datamigrations locally against the development database with `rollback: true` rather than committing specs that will run indefinitely after the migration is complete. Remove `rollback: true` before committing the datamigration. Add lasting specs only when the datamigration contains behavior that warrants ongoing coverage.
- Run datamigrations through their standard `Datamigration::Runner` when testing them in development. A reasonable, limited number of resulting development `DatamigrationRun` records is acceptable. The runner's `AdminMailer.datamigration_run` notification cannot send external email in development because delivery uses `letter_opener`; it is safe if the resulting Sidekiq job remains queued.
- Apply branch migrations to both development and test databases with:

  ```sh
  DISABLE_TYPELIZER=1 bin/rails db:migrate db:test:prepare
  ```

  Keep `DISABLE_TYPELIZER=1` on this command. During Rails initialization, automatic Typelizer generation can load a serializer that references a table which the pending branch migration has not created yet. That can make the command fail before `db:migrate` gets the opportunity to create the table, even though migrations without that dependency may work without the flag.

- Before switching away from a branch with migrations that are not on `origin/main`, roll those migrations back so the development and test databases match the state of `main`:

  ```sh
  bin/rails db:rollback db:test:prepare
  ```

  Roll back as many migrations as necessary. Inspect the diff before restoring anything, then restore only generated-file changes caused by the rollback, especially `db/schema.rb`, from `HEAD`; do not discard unrelated work. After returning to the migration branch, apply its migrations again.

## Generated files

- Never edit `db/schema.rb` manually. Generate it by running the appropriate database migration command.
- Generate model annotations with `bin/annotaterb models`; do not edit the annotation blocks manually.
- Do not edit generated TypeScript files directly. Regenerate serializer types under `app/javascript/types/serializers/` with `bin/rails typelizer:generate`. Regenerate bootstrap and response types under `app/javascript/types/bootstrap/` and `app/javascript/types/responses/` with `bin/json-schemas-to-typescript`.
