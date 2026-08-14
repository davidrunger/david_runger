# Datamigrations

Datamigrations make one-time changes to application data. They are separate from schema migrations (which run automatically when deployed). To run a datamigration in production, you must first deploy the file, and then manually execute it.

## Create a datamigration

Generate a timestamped datamigration with:

```sh
bin/rails generate datamigration NAME
```

The generated file begins with the exact commands for running that datamigration locally and in production.

## Run locally

Use the local command shown at the top of the generated file:

```sh
bin/rails runner db/datamigrate/TIMESTAMP_name.rb
```

New datamigrations run in a transaction with `rollback: true`, so their changes are rolled back after the run. This makes the generated default suitable for checking the migration's behavior locally without persisting its changes. Change that setting only when persistent local changes are intentional.

## Run in production

After the datamigration file has deployed, run the production command from a developer machine:

```sh
bin/run-datamigration db/datamigrate/TIMESTAMP_name.rb
```

This command connects to the production application, sets the developer identity required by the runner, and sends output to both the terminal and production logging. The runner also records the run in `DatamigrationRun` and notifies administrators when it starts.

Datamigrations are not automatically run during deployment. Run a datamigration only once unless repeating it is explicitly safe and intended.
