# Repository Guidelines

## Project Purpose

PSStarr is a reusable PowerShell 7 client module for Radarr, Sonarr, and Prowlarr.
Keep this repository focused on application configuration, HTTP transport, and broadly useful API endpoint wrappers.
Opinionated automation, notification behavior, scheduling, and workflow-specific settings belong in consuming projects such as `Just-A-Bunch-Of-Starr-Scripts`.

Favor a small, coherent public API over narrow functions designed for one existing script. Implement read operations first, but design the transport for all HTTP methods.

## Established Decisions

- Radarr and Sonarr require API v3; Prowlarr uses API v1. Do not add Lidarr, Readarr, or Whisparr.
- Supported JSON GET routes expose typed parameters rather than raw query hashtables. Serialize dates as ISO 8601, repeat ordinary array query keys, and use CSV only where the upstream controller requires it. Validate route-specific parameter combinations.
- Saved configuration encrypts API keys only. Windows defaults to current-user/current-host DPAPI; portable AES-256 requires an external Base64-encoded 32-byte key in `PSSTARR_AES_KEY`; plaintext must be explicit on Windows. Never fall back to plaintext after an encryption failure.
- Provider, host, error, and log responses must mask recognizable credentials. Redacted configuration output must never be submitted as an update. Successful calls are not logged; operational logging is controlled by `PSSTARR_LOG_DISABLED` and `PSSTARR_LOG_DIRECTORY`.
- GETs that search releases or Prowlarr indexers can contact providers and consume quotas; manual-import reads inspect server files. Filesystem browsing, feeds, authentication UI, localization, static/binary downloads, log downloads, and deprecated endpoints stay excluded.
- Consumer-required writes are limited to tag creation, command submission, Radarr movie-tag and collection-monitoring updates, and Sonarr series-tag updates. All state changes require `SupportsShouldProcess`; collection monitoring can trigger Radarr automation.
- Unit tests use fake credentials and mocked HTTP. Live checks are opt-in and must never print credentials or response bodies. The saved-connection baseline covers safe Radarr, Sonarr, and Prowlarr reads; rerun the full live matrix after public parameter or configuration changes.
- Application-facing commands use `InstanceName` for saved-connection selection; only `*-PSStarrInstance` configuration commands use `Name` for the configuration record itself.
- Preserve predictable output shapes: ordinary collections stream zero or more resource objects, paged endpoints return their paging envelope, ID routes return one resource, and filter commands remain list searches. Do not fabricate empty arrays or placeholder objects.
- Support property-name pipeline binding only for natural parent-to-child reads. Avoid implicit pipeline behavior for searches and server-filesystem inspection.
- Apply consistent parameter semantics: positive resource IDs and ID arrays, paging values starting at 1, typed booleans, descriptive `*IdFilter` names, ISO 8601 dates, and early validation of invalid combinations and reversed date ranges.
- Shared commands must expose an application discriminator where explicit credentials are accepted and reject unsupported applications before transport. Prefer application-specific facades when Radarr and Sonarr contracts differ.
- Live verification must cover empty results, paged envelopes, ID/list behavior, explicit and saved connections, and application mismatch errors. Provider searches can consume quotas; manual-import reads inspect server files. Configure each application's recycle bin before destructive media tests.
- ModuleBuilder output is generated and ignored; publish built artifacts from a clean checkout. A public 1.0.0 release still needs a license, root README, release notes, and a repeatable publishing workflow.

## Architecture

Use `Invoke-StarrApiRequest` as the single HTTP boundary. It should resolve a named connection, construct versioned URLs,
add authentication headers, serialize query/body data, invoke the request, and return deserialized responses.
It must sanitize API keys from verbose output and errors.

Public endpoint commands should provide discoverability and delegate transport concerns.
Prefer consistent names such as `Get-StarrSystemStatus`, `Get-StarrTag`, and application-specific commands such as `Get-StarrRadarrMovie`.
Keep URL construction and direct `Invoke-RestMethod` calls out of endpoint wrappers.

## Configuration

Store only named connections with `Name`, `Application`, `Url`, and `ApiKey`. Support multiple instances, for example `RadarrMain` and `Radarr4K`. `Set-PSStarrInstance` must support partial updates without requiring unchanged values; creation must still require a complete valid record.
Use the PoshCode `Configuration` module unless the design is explicitly revisited; do not introduce PSFramework solely for logging.
Finalize module author metadata before persisting user settings because Configuration derives storage paths from module name and author.

Never log, display, commit, or include real API keys in fixtures. Keep explicit `-Url` and `-ApiKey` parameters available for ephemeral and CI use where practical.

## Coding and Testing

Follow PowerShell approved verbs, singular nouns, PascalCase parameters, four-space indentation, comment-based help, and `SupportsShouldProcess` for state-changing commands.
Public filenames must match exported function names.

Use Pester for unit tests. Mock `Invoke-StarrApiRequest` in endpoint tests and mock `Invoke-RestMethod` only in transport tests.
Cover URL normalization, query serialization, API-version handling, sanitized errors, configuration persistence, list responses, ID lookup, and application-specific differences.
Keep integration tests opt-in and driven by environment variables.

## Delivery Order

Complete public `InstanceName` consistency and partial configuration updates, then run the full local live matrix before release-readiness work. Maintain an endpoint inventory by application and supported API version so GET coverage remains measurable.

## PowerShell Style

- Put every parameter declaration on its own line.
- Put parameter attributes, the parameter type, and the parameter variable on separate lines.
- Apply equivalent validation consistently to parameters with equivalent semantics. Named instances and API keys must reject null, empty, and whitespace-only values; explicit URLs must use the shared URL validator.
- Use four-space indentation.
- Leave a blank line between distinct actions, including assignments, conditionals, loops, transport calls, and output construction.
- Expand conditionals and loops across multiple lines when their bodies perform assignments, contain multiple actions, or would be harder to scan inline.
- A simple single-action conditional may remain compact only when readability is not reduced.
- Prefer readable multi-line hashtables over inline hashtables in implementation code.
- ModuleBuilder source files must contain exactly one function per script. The filename must match the function name for public and private functions.
- Keep logging plain-text and human-readable. Do not add enterprise-specific formats unless the project requirements explicitly change.
- Every function must include comment-based help with `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER` for every parameter, `.EXAMPLE`, `.INPUTS`, and `.OUTPUTS` sections.
- Begin every `.DESCRIPTION` with `This function`.
- Include more than one example when a function has meaningfully different use cases or parameter sets.
- For functions that accept or return pipeline objects, use fully qualified .NET type names in `.INPUTS`, `.OUTPUTS`, and `[OutputType()]`, keep output types consistent, and add a brief description. For no-input or no-output functions, document `None.` followed by the standard explanatory sentence.
- Do not add `.LINK` sections unless project requirements change.
- Route operational failures at public command boundaries through structured error records and the shared error handler; keep parameter validation in PowerShell validation attributes or parameter sets.
- Log operational failures, but do not log successful API calls by default. Expected user-input errors may be emitted without being logged.
