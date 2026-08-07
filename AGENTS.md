# Repository Guidelines

## Ruby conventions

- When a Ruby method's computed result is reused, prefer the repository's `Memoization` pattern over assigning a same-named local variable from `self`, such as `value = self.value`, solely to avoid recomputation. Add `prepend Memoization` to the class and decorate the method with `memoize \`.

## Local tooling

- Prefer repository binstubs, such as `bin/rails` and `bin/rspec`, over commands that bypass them.
- Keep Spring enabled for local Rails commands because it substantially speeds up tests and other work. Disable Spring only for a concrete reason, not as a routine workaround.

## Tests and coverage

- Run targeted specs with `bin/rspec path/to/spec.rb` while developing.
- Run targeted linters on changed files when they provide useful feedback: `bin/rubocop` for Ruby; `pnpm exec oxlint` for JavaScript, TypeScript, and Vue; `pnpm exec stylelint` for CSS, SCSS, and Vue; `pnpm exec prettier` for Prettier-managed files; and `shellcheck` for shell scripts. Use appropriate check or autocorrect flags for the task, and inspect the diff after any autocorrection. Do not assume that personal helper commands such as `lint` are installed.
- CI is the portable broad-check mechanism. `bin/githooks/pre-push` may also start broad linting on machines that have its external helper commands installed, but do not assume that setup exists and do not push merely to trigger it.
- Do not routinely run Vitest or TypeScript checks locally. Run them when the task particularly benefits from them; otherwise rely on CI.
- Do not run `bin/run-tests` locally by default. It is primarily a CI command, and CI may catch issues through checks that are intentionally not run during local development.
- Maintain 100% line coverage for Ruby code included in coverage, apart from lines that are explicitly ignored. Coverage may come from any combination of spec types; it does not need to come entirely from unit specs.
- Do not run the entire test suite locally solely to confirm total coverage. CI and Codecov perform the authoritative full-suite coverage check.

## Test design

- When an RSpec example description contains an apostrophe, delimit the string with double quotes rather than escaping the apostrophe in a single-quoted string. RSpec omits the escape character from documentation output, so keeping the source text identical to the rendered description makes the example searchable.
- Specs under `spec/controllers/api/` automatically receive `request_format: :json` through derived metadata in `spec/spec_helper.rb`. Do not repeat that metadata on individual API controller spec groups unless the spec intentionally needs different format behavior.
- Keep specs focused on the behavior under test. Set up only attributes and conditions that are relevant to that behavior.
- Express required relationships directly instead of relying on incidental fixture identities. For example, when an owner must differ from `user`, prefer `User.excluding(user).first!` over naming a fixture that merely happens to represent another user.
- Avoid confounding conditions in regression specs. Construct the example so that the rule under test, not an unrelated validation, privacy setting, authorization rule, or fixture detail, determines the outcome.
- Before adding a test-specific condition, ask whether changing that condition should affect the expected result. If not, omit it.

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
- More generally, when a file says that it is generated, find and run its owning generator instead of editing the output.
