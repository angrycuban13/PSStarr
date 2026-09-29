# Repository Guidelines

## Scope and Applications

- PSStarr is a PowerShell 7 client for Radarr, Sonarr, and Prowlarr.
- Radarr and Sonarr use API v3. Prowlarr uses API v1. Do not add other Starr applications.
- Keep this module focused on configuration, HTTP transport, and broadly useful API wrappers.
- Keep scheduling, notifications, retention, and workflow automation in consuming projects.
- Favor a small public API over complete upstream coverage. Add commands only for broad utility or confirmed consumer needs.
- Exclude filesystem browsing, feeds, authentication UI, localization, downloads, and deprecated endpoints.

## API Contracts

- Use `Invoke-StarrApiRequest` as the only HTTP boundary. Keep URL construction and `Invoke-RestMethod` out of endpoint wrappers.
- Expose typed query parameters. Serialize dates as ISO 8601. Repeat array keys unless the upstream controller requires CSV.
- Validate route-specific combinations and reversed date ranges before transport.
- Require positive IDs and ID arrays. Start paging values at 1. Use typed booleans and descriptive `*IdFilter` names.
- Stream ordinary collections. Return paging envelopes from paged routes and one resource from ID routes. Keep filters as list searches.
- Do not fabricate empty arrays or placeholder objects.
- Add stable `PSStarr.*` type names without removing upstream properties. Keep complete properties available through explicit selection.
- Use property-name pipeline binding only for natural parent-to-child reads. Exclude searches and server-filesystem inspection.
- Use `InstanceName` in application commands. Use `Name` only in `*-PSStarrInstance` commands.
- Require an application discriminator when shared commands accept explicit credentials. Reject unsupported applications before transport.
- Prefer application-specific commands for different Radarr and Sonarr contracts.

## Mutations and Side Effects

- Limit writes to tag resources, command submission, supported media-tag updates, and Radarr collection monitoring.
- Add typed command facades only for broadly useful refresh, rescan, rename, and scoped searches.
- Require `SupportsShouldProcess` for every state change. Document upstream work and provider quota risks.
- Treat `Invoke-StarrCommand` as the advanced command interface. Keep `Start-StarrCommand` only for compatibility.
- Use `Action` with `Add` and `Remove` for media tag changes.
- Accept tag names where tags apply to media. Resolve names through the tag endpoint and warn when a name is missing.
- Use `Remove-StarrTag` to delete tag resources. Use `Set-*Tag -Action Remove` to remove tags from media.

## Configuration and Security

- Expose named connections with `Name`, `Application`, `Url`, and `ApiKey`. Require complete records only for creation.
- Use the PoshCode `Configuration` module unless the design changes. Do not add PSFramework only for logging.
- Treat the module name and author as storage identifiers. Require migration and compatibility tests before changing them.
- Encrypt only saved API keys. Keep encryption metadata out of public connection objects.
- Use current-user and current-host DPAPI by default on Windows. Require explicit plaintext selection.
- Require `PSSTARR_AES_KEY` to contain a Base64-encoded 32-byte key for portable AES-256.
- Never fall back to plaintext after encryption fails.
- Mask credentials in provider, host, error, and log data. Never reuse redacted configuration as an update.
- Never log, display, commit, or use real credentials in fixtures.
- Control operational logging with `PSSTARR_LOG_DISABLED` and `PSSTARR_LOG_DIRECTORY`. Do not log successful calls by default.
- Keep explicit `Url` and `ApiKey` parameters available for ephemeral and CI use where practical.

## Errors and Tests

- Route operational failures through the shared error handler at public boundaries. Log only redacted operational failures.
- Handle expected input errors through validation attributes or parameter sets. Do not log them by default.
- Mock `Invoke-StarrApiRequest` in endpoint tests. Mock `Invoke-RestMethod` only in transport tests.
- Use fake credentials. Cover URLs, queries, API versions, redaction, persistence, output shapes, and application differences.
- Keep live tests opt-in. Never print credentials or response bodies.
- Test safe saved and explicit connections for all applications. Cover empty, list, ID, paged, and mismatch behavior.
- Run the full live matrix after public parameter or configuration changes.
- Limit provider searches to the smallest useful sample. Treat manual-import reads as server-filesystem inspection.

## Help and Documentation

- Treat source comment-based help as the command contract.
- Generate `docs/command-reference` from the built module with `ci/New-ModuleDocs.ps1`.
- Fix source help or the generator. Do not edit generated command pages directly.
- Follow `docs/contributing.md` for documentation commands and validation.
- Keep `PSStarr/Output` and `site` untracked.

## Releases and Repository Output

- Run `PSStarr/tools/Test-Release.ps1` for module, packaging, help, or release changes.
- Also run the strict documentation build when a public command changes.
- Update the manifest and dated changelog for source or packaging changes. Use `PSStarr/tools/Prepare-Release.ps1`.
- Let pull requests validate releases. Publish when a manifest change reaches `main`.
- Use `workflow_dispatch` only to retry the exact stable version on `main`.
- Treat each CI job as a clean machine. Install dependencies before use. Do not expect `needs` to transfer machine state.
- Publish the exact validated artifact. Keep retries idempotent. Use `CHANGELOG.md` for release notes.
- Build and publish from a clean checkout. Never hand-edit, commit, or publish ModuleBuilder output.
- Treat tracked specifications and coverage documents as dated research. Re-audit them when contracts or consumer needs change.
- Keep temporary research untracked unless the user requests a durable artifact.

## PowerShell Style

- Use approved verbs, singular nouns, PascalCase parameters, and four-space indentation.
- Put each parameter on its own line. Put its attributes, type, and variable on separate lines.
- Apply equal validation to equal semantics. Reject blank instance names and API keys. Use the shared URL validator.
- Leave blank lines between distinct actions. Expand conditionals and loops when compact forms reduce readability.
- Prefer multi-line implementation hashtables.
- Keep one function in each source file. Match each public and private filename to its function name.
- Keep logs plain-text and human-readable.
- Give every function `.SYNOPSIS`, `.DESCRIPTION`, every `.PARAMETER`, `.EXAMPLE`, `.INPUTS`, and `.OUTPUTS`.
- Begin each `.DESCRIPTION` with `This function`. Add multiple examples for meaningfully different uses.
- Use fully qualified .NET pipeline types. Keep `[OutputType()]`, `.INPUTS`, and `.OUTPUTS` consistent.
- Document no input or output as `None.` followed by the standard explanation.
- Do not add `.LINK` sections unless project requirements change.
