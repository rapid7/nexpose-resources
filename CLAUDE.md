# CLAUDE.md

Guidance for AI coding assistants working in this repository.

## What this repo is

`nexpose-resources` is an open-source (BSD 3-Clause) collection of standalone scripts for Nexpose / InsightVM
customers. Nothing here is built, packaged or consumed by another repo; users copy a script and run it
against their own console. Cortex marks it `target:not-deployed`.

## Layout

- `scripts/<area>/<resource>/` - one directory per resource, with a `README.md` and a subdirectory per
  language (`ruby/`, `powershell/`). Areas: `asset_groups`, `discovery_connections`, `general_api`,
  `metrics`, `schedules`, `sites`, `snippets`, `users`.
- Ruby scripts use the `nexpose` gem (nexpose-client) and connect with `Connection.new(host, user, password)`.
  The PowerShell scripts call the legacy XML API (for example `-APIVersion 1.1`).
- `scripts/discovery_connections/aws_discovery_connection/` is the only resource with a `Gemfile` and a
  config file (`aws_configuration.yml`).
- `sql-queries/` - placeholder only (`.gitkeep`).
- `.github/CONTRIBUTING.md` - the contribution rules; `.github/PULL_REQUEST_TEMPLATE.md`.

## Build and test

There is no build, test suite, linter or CI. To try a Ruby script: `gem install nexpose`, edit the
placeholder connection values, then `ruby <script>.rb` against a test console. Never run one against a
production console while developing it.

## Conventions

From `CONTRIBUTING.md`:

- Every resource needs a readme that says what it does and how to use it, with examples.
- Use the right file extension (`.rb`, `.py`, `.ps1`; `.sql` or `.txt` for SQL).
- Mark values the user must replace with comments. Never commit real usernames, passwords, hostnames or IPs;
  use `example.com`, `127.0.0.1` or private ranges.
- Contributions are BSD 3-Clause licensed.

Ruby code uses 2-space indentation and `#!/usr/bin/env ruby`.

## Gotchas

- The top-level README describes SQL queries for SQL Query Export, but `sql-queries/` is empty; the README
  points readers to the knowledge base instead.
- The AWS `Gemfile` has no `source` line and pulls `nexpose` over `git://github.com/...`, a protocol GitHub no
  longer serves, so `bundle install` fails until it is changed to `https://`.
- `aws_discovery_connection_creator.rb` also requires `eso`, which ships inside the `nexpose` gem.
- The repo is open source and takes contributions from forks. Treat every file as customer-facing: no internal hostnames, ticket IDs or credentials.
