# Repository Guidelines

## Ruby conventions

- When a Ruby method's computed result is reused, prefer the repository's `Memoization` pattern over assigning a same-named local variable from `self`, such as `value = self.value`, solely to avoid recomputation. Add `prepend Memoization` to the class and decorate the method with `memoize \`.

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

- When adding a new model class, consider adding realistic baseline records for the primary fixtures to the FixtureBuilder setup when the domain naturally calls for them. This lets specs reuse those records for faster setup and gives feature specs a more representative database state, increasing the chance that relevant data-shape bugs surface.
- Before running feature specs that exercise changed frontend assets, start the live Vite server with `./node_modules/.bin/vite --force` in a separate terminal and leave it running while iterating. This ensures that each feature-spec run uses the current source without rebuilding assets after every edit. When a task runner starts Vite as a managed background process instead, confirm that the server is ready before running specs and stop it when testing is complete.
- When running a live Vite server is impractical, run `RAILS_ENV=test bin/vite build` immediately before the relevant feature specs. Repeat the build after every frontend change; otherwise feature specs can silently exercise stale compiled assets.
- Run targeted specs with `bin/rspec path/to/spec.rb` while developing.
- Run targeted linters on changed files when they provide useful feedback: `bin/rubocop` for Ruby; `pnpm exec oxlint` for JavaScript, TypeScript, and Vue; `pnpm exec stylelint` for CSS, SCSS, and Vue; `pnpm exec prettier` for Prettier-managed files; and `shellcheck` for shell scripts. Use appropriate check or autocorrect flags for the task, and inspect the diff after any autocorrection. Do not assume that personal helper commands such as `lint` are installed.
- Do not routinely run Vitest or TypeScript checks locally. Run them when the task particularly benefits from them; otherwise rely on CI.
- Do not run `bin/run-tests` locally by default. It is primarily a CI command, and CI may catch issues through checks that are intentionally not run during local development.
- When an expected asset-size change requires updating `Test::Tasks::RunFileSizeChecks::CONSTRAINTS`, round the reported size to the nearest whole KiB and set the constraint to a 10 KiB range centered on that value (rounded size minus 5 through rounded size plus 5).
- Maintain 100% line coverage for Ruby code included in coverage, apart from lines that are explicitly ignored. Coverage may come from any combination of spec types; it does not need to come entirely from unit specs.
- Do not run the entire test suite locally solely to confirm total coverage. CI performs the authoritative full-suite coverage check; Codecov also reports full-suite coverage.

## Test design

- Specs under `spec/controllers/api/` automatically receive `request_format: :json` through derived metadata in `spec/spec_helper.rb`. Do not repeat that metadata on individual API controller spec groups unless the spec intentionally needs different format behavior.
- When a spec needs a fixture record related to another fixture, obtain it through the relevant association rather than looking up a separately named fixture. This keeps the relationship explicit and avoids relying on incidental fixture identities.

## Database migrations

- Generate schema migrations with `bin/rails generate migration NAME ...` instead of creating migration files manually. This preserves Rails generator conventions, including the correct migration class version.
- Generate datamigrations with the repository's custom generator:

  ```sh
  bin/rails generate datamigration NAME
  ```

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
