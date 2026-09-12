# GET Parameter Audit

The supported JSON GET routes were compared with the official Radarr `master`
API v3, Sonarr `main` API v3, and Prowlarr `master` API v1 OpenAPI documents on
2026-09-12.

## Result

Every documented query parameter on an included GET route has a corresponding
typed PSStarr parameter. Path identifiers are exposed separately from query
filters, and wrappers do not expose a raw query hashtable.

The audit corrected two issues:

- Calendar `start` and `end` values are now serialized with the round-trip
  ISO 8601 (`o`) format instead of the caller's current culture.
- Shared history validates parameters by selected route. Paged-only filters
  cannot leak into `history/since`, `history/movie`, or `history/series`, and
  named event types cannot be sent to the paged endpoint that expects numeric
  event identifiers.

Prowlarr statistics intentionally converts indexer, protocol, and tag arrays to
comma-separated values because that controller parses CSV strings. Other array
queries use repeated query keys through the shared transport.

## Boundaries

Route coverage is not a promise that every future application release preserves
the same contract. Upstream branch specifications can change after this dated
audit. Filesystem, feed, authentication, localization, static-resource, binary
download, and deprecated routes remain excluded as documented in the endpoint
inventory.

Live verification covered safe system status, health, tags, quality profiles,
root folders, and disk-space reads for saved Radarr and Sonarr connections. It
did not execute indexer searches, filesystem scans, or write operations.
