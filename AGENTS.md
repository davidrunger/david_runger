# Repository Guidelines

## Text and source formatting

- Generally use ASCII characters in code and commit messages.
- Use non-ASCII characters only when there is a specific reason, such as rendering that character to a user.
- Keep code generally hard-wrapped in accordance with repository formatters, linters, and surrounding style.
- Do not hard-wrap prose or template text solely to enforce a fixed line width. Let editors and viewers visually wrap long lines. In particular, keep long text paragraphs in `.vue` and Haml templates on a single source line unless line breaks are semantically or structurally useful. This avoids reflow-only diffs when the text changes.
- When a Ruby method's computed result is reused, prefer the repository's `Memoization` pattern over assigning a same-named local variable from `self`, such as `value = self.value`, solely to avoid recomputation. Add `prepend Memoization` to the class and decorate the method with `memoize \`.

## Git workflow

- When starting a change that does not already have a designated branch, create a dedicated branch from the latest `origin/main` before editing. When resuming work that already has a task branch, continue using that branch rather than creating another. Treat starting a new branch anywhere other than `origin/main` as a rare exception that requires explicit direction. A typical branch setup is:

  ```sh
  git fetch origin main
  git switch -c <branch-name> origin/main
  ```

- After creating the branch, configure it to track `origin/main`:

  ```sh
  git branch --set-upstream-to=origin/main
  ```

  This keeps the branch's ahead/behind counts relative to `origin/main`.

- Do not push branches or otherwise modify remote or GitHub state unless the user explicitly requests it.
- When explicitly asked to push, send the current branch to the same-named branch on `origin` while preserving `origin/main` as the upstream. Use a command compatible with the machine's Git configuration; do not use `-u` or otherwise change the upstream to `origin/<branch-name>`.
- Before the branch has been pushed to a remote, keep its work in a single commit and amend that commit as needed.
- Do not rewrite a commit after it has been pushed. Make subsequent changes in a new commit. That new commit may itself be amended until it is pushed.

## Commit messages

- Format commit titles as `[subject area] Imperative title [JIRA-123]`.
- Choose the narrowest useful subject area that identifies the principal code or concern changed. Consult recent commit history for analogous scopes instead of defaulting to a broad label. Subject areas are not limited to a fixed list and may identify a path, subsystem, class, or file; for example, `[spec/features/logs]` may be more useful than `[specs]`.
- Use the subject area to name the area affected and the imperative title to describe the specific change within that area. Do not repeat the same information in both parts; each part must contribute distinct, useful information.
- When the user associates a Jira issue key, such as `LOG-11`, with the requested change, append `[LOG-11]` to the commit title even if the user does not separately request that in the commit instructions. Omit the Jira suffix only when no issue key applies.
- Keep the entire commit title at or below 69 characters.
- Prefer clear, direct commit titles. Shorter wording is better when it is equally clear or clearer, but do not sacrifice useful specificity merely to minimize length.
- Write a detailed commit message body. Include relevant context, history, documentation links, reasoning and motivation, and consciously chosen tradeoffs where they will help a future reader understand the change.

## Local tooling

- Prefer repository binstubs, such as `bin/rails` and `bin/rspec`, over commands that bypass them.
- Use `pnpm` for JavaScript package management.
- Keep Spring enabled for local Rails commands because it substantially speeds up tests and other work. Disable Spring only for a concrete reason, not as a routine workaround.
- Do not add a dependency in any environment, including development or test, without the user's explicit consent. Dependency additions carry supply-chain, vulnerability, and local-machine risks.

## Tests and coverage

- Run targeted specs with `bin/rspec path/to/spec.rb` while developing.
- Run targeted linters on changed files when they provide useful feedback: `bin/rubocop` for Ruby; `pnpm exec oxlint` for JavaScript, TypeScript, and Vue; `pnpm exec stylelint` for CSS, SCSS, and Vue; `pnpm exec prettier` for Prettier-managed files; and `shellcheck` for shell scripts. Use appropriate check or autocorrect flags for the task, and inspect the diff after any autocorrection. Do not assume that personal helper commands such as `lint` are installed.
- CI is the portable broad-check mechanism. `bin/githooks/pre-push` may also start broad linting on machines that have its external helper commands installed, but do not assume that setup exists and do not push merely to trigger it.
- Do not routinely run Vitest or TypeScript checks locally. Run them when the task particularly benefits from them; otherwise rely on CI.
- Do not run `bin/run-tests` locally by default. It is primarily a CI command, and CI may catch issues through checks that are intentionally not run during local development.
- Maintain 100% line coverage for Ruby code included in coverage, apart from lines that are explicitly ignored. Coverage may come from any combination of spec types; it does not need to come entirely from unit specs.
- Do not run the entire test suite locally solely to confirm total coverage. CI and Codecov perform the authoritative full-suite coverage check.

## Test design

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
