# Release Readiness

Reviewed on 2026-09-12.

## Ready

- ModuleBuilder produces a loadable PowerShell 7 module and an explicit export
  list. The current build exports 96 public functions.
- The manifest identifies Radarr, Sonarr, and Prowlarr, declares PowerShell Core
  compatibility, provides gallery tags, and links to the project repository.
- Generated `Output` content remains ignored. Release automation should build a
  clean artifact and publish that artifact; generated module files should not be
  committed to source control.
- Unit coverage, analyzer validation, configuration encryption, sanitized error
  handling, and opt-in live-test guidance are present.

## Blocking a public 1.0.0 release

- Choose and add a license, then set `LicenseUri` in the manifest. The current
  copyright statement is not a substitute for an open-source license.
- Add a root README with installation, quick-start, supported applications,
  encryption-key ownership, and security guidance.
- Add release notes or a changelog and decide whether the first public package
  remains `1.0.0` or uses a prerelease label while live coverage expands.
- Add a repeatable packaging/publishing workflow that builds from a clean
  checkout, runs analyzer and Pester, and verifies the produced manifest.

## Non-blocking follow-up

- Add a saved Prowlarr connection and extend safe live verification to it.
- Expand opt-in live checks gradually; never make indexer searches or mutations
  part of the default test run.
