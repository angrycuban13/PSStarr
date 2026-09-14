# Changelog

All notable changes to PSStarr are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-09-14
### Added

- Radarr API v3, Sonarr API v3, and Prowlarr API v1 support.
- Named saved connections with explicit URL and API-key alternatives.
- Windows DPAPI and portable AES-256 API-key protection with fail-closed behavior.
- Shared HTTP transport with normalized URLs, typed query serialization, application validation, credential sanitization, and structured errors.
- Broad read coverage for media, files, collections, profiles, providers, queues, history, calendars, blocklists, health, system resources, and configuration resources.
- Consumer-required tag, monitoring, refresh, rescan, rename, and controlled search operations with `ShouldProcess` support.
- Stable `PSStarr.*` type names and default views while retaining complete upstream response properties.
- Credential-safe errors, provider responses, configuration output, and operational failure logging controls.
- Clean-checkout validation and PowerShell Gallery publishing workflow.

### Changed

- `Invoke-StarrCommand` is the canonical advanced command-submission interface.
- Application-facing commands use `InstanceName`; the former `Name` spelling remains an alias.

### Deprecated

- `Start-StarrCommand` remains compatible for the 1.0.0 transition; new code should use `Invoke-StarrCommand`.
