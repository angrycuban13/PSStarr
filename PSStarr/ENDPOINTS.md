# Supported GET Endpoint Inventory

Source specifications:

- Radarr v3: <https://raw.githubusercontent.com/Radarr/Radarr/develop/src/Radarr.Api.V3/openapi.json>
- Sonarr v3: <https://raw.githubusercontent.com/Sonarr/Sonarr/develop/src/Sonarr.Api.V3/openapi.json>
- Prowlarr v1: <https://raw.githubusercontent.com/Prowlarr/Prowlarr/master/src/Prowlarr.Api.V1/openapi.json>

Parameter coverage for included routes was audited on 2026-09-12. See
`docs/Parameter-Audit.md`. Prowlarr v1 is an application-specific exception to
the Radarr/Sonarr v3 baseline.

## Shared wrappers

API info, auto-tagging and schema, backups, blocklist, calendar, commands, custom formats and schema,
disk space, download clients and schema, health, history, import lists and schema, indexers and schema, notifications and schema,
quality profiles and schema, quality definitions and limits, queue/details/status, remote-path mappings, root folders, tags/details,
system tasks, and updates.

## Radarr wrappers

Movies, collections, movie files, credits, wanted missing/cutoff, and movie lookup by term, IMDb ID, or TMDB ID.
Import-list exclusions use exclusions/paged and exclusions/{id}.
Alternative titles use alttitle (movieId/movieMetadataId filters) and alttitle/{id}.
Extra-file records use extrafile with an optional movieId filter; no file content is downloaded.

## Sonarr wrappers

Series, episodes, episode files, wanted missing/cutoff, and series lookup.
Import-list exclusions use importlistexclusion/paged and importlistexclusion/{id}.

## Additional shared settings GET coverage

Metadata providers (metadata and metadata/{id}), metadata/schema, languages
(language and language/{id}), delay profiles (delayprofile and delayprofile/{id}),
and custom filters (customfilter and customfilter/{id}). These are application
settings. Release profiles use releaseprofile and releaseprofile/{id} in both applications.
These retain Starr names, unlike PSStarr's local instance configuration.

Exclusion commands return one page with metadata intact; no automatic all-page
fetching or fallback to deprecated unpaged routes. The routes were checked against
Radarr master and Sonarr main API v3 specifications.

## Intentionally excluded

Lidarr, Readarr, and Whisparr are outside the active implementation scope.

## Prowlarr v1 coverage

Dedicated commands cover applications/schema, application profiles/schema,
indexer proxies/schema, indexer categories/status/statistics, searches, paged and
scoped history, and development configuration. Compatible shared named-connection
reads automatically use API v1. See `docs/Prowlarr.md` for safety boundaries.

## Consumer-required write coverage

POST and DELETE tag, POST command, PUT Radarr movie/editor and collection, and
PUT Sonarr series/editor are exposed through commands with `SupportsShouldProcess`.
Typed command facades cover Radarr movie refresh/search/rename and Sonarr series
refresh/search plus episode-file rename.
See `docs/Consumer-Endpoint-Coverage.md`.

## Quality definition coverage (Radarr and Sonarr v3)

| GET path | Command |
| --- | --- |
| /api/v3/qualitydefinition | Get-StarrQualityDefinition |
| /api/v3/qualitydefinition/{id} | Get-StarrQualityDefinition -QualityDefinitionId |
| /api/v3/qualitydefinition/limits | Get-StarrQualityDefinitionLimit |

Verified against both linked upstream specifications on 2026-09-09; no live-server validation.

## Other exclusions

Authentication UI, static resources, filesystem browsing, media-cover binary responses,
log files, localization, calendar feeds, raw system routes, shutdown/restart operations,
and other non-GET state-changing endpoints.

All versioned wrappers currently target API v3 by default. `Get-StarrApiInfo` calls authenticated
`GET /api` explicitly; API discovery is not performed automatically.

## Remaining GET routes for review

Original audit: 2026-09-10. All 50 checklist routes implemented and verified with mocked tests on 2026-09-12.
See [command mapping and safety notes](docs/GET-Coverage.md).
Sources used for this count: [Radarr master](https://raw.githubusercontent.com/Radarr/Radarr/master/src/Radarr.Api.V3/openapi.json)
and [Sonarr main](https://raw.githubusercontent.com/Sonarr/Sonarr/main/src/Sonarr.Api.V3/openapi.json).
Branch specifications can change; this is a dated route-level audit, not a claim of full parameter or live-server coverage.

| Application | Implemented | Missing / review backlog | Intentionally excluded | Deprecated, not targeted | Total |
| --- | ---: | ---: | ---: | ---: | ---: |
| Radarr | 106 | 0 | 18 | 1 | 125 |
| Sonarr | 98 | 0 | 19 | 4 | 121 |
| Total | 204 | 0 | 37 | 5 | 246 |

Each application/path pair counts separately. Shared paths therefore count twice.
A route is not the same as a public function: one command may cover several routes.
Checked entries have implemented wrappers; the original checklist is retained for traceability.

### Review considerations

- Application settings remain application commands (`Starr`), not local module configuration (`PSStarr`).
- Host settings and structured logs may contain sensitive data; review response handling before adding wrappers.
- `manualimport` scans server files, `release` can contact indexers/cache results, and `rename` previews changes. No wrapper requests imports, downloads, or renames.
- Movie/series folder routes calculate names, not filesystem browsing; implemented after controller verification.
- `/ping` is unversioned. It is listed explicitly, not presented as an API v3 route.
- Deprecated routes are outside this backlog: Radarr `exclusions`; Sonarr `importlistexclusion`, `languageprofile`, `languageprofile/{id}`, and `languageprofile/schema` (all under `/api/v3/`).
- Structured `/api/v3/log` is listed for review; excluded log-file download routes are separate.

### Radarr: 26 routes

- [x] `GET /api/v3/config/downloadclient`
- [x] `GET /api/v3/config/downloadclient/{id}`
- [x] `GET /api/v3/config/host`
- [x] `GET /api/v3/config/host/{id}`
- [x] `GET /api/v3/config/importlist`
- [x] `GET /api/v3/config/importlist/{id}`
- [x] `GET /api/v3/config/indexer`
- [x] `GET /api/v3/config/indexer/{id}`
- [x] `GET /api/v3/config/mediamanagement`
- [x] `GET /api/v3/config/mediamanagement/{id}`
- [x] `GET /api/v3/config/metadata`
- [x] `GET /api/v3/config/metadata/{id}`
- [x] `GET /api/v3/config/naming`
- [x] `GET /api/v3/config/naming/examples`
- [x] `GET /api/v3/config/naming/{id}`
- [x] `GET /api/v3/config/ui`
- [x] `GET /api/v3/config/ui/{id}`
- [x] `GET /api/v3/importlist/movie`
- [x] `GET /api/v3/indexerflag`
- [x] `GET /api/v3/log`
- [x] `GET /api/v3/manualimport`
- [x] `GET /api/v3/movie/{id}/folder`
- [x] `GET /api/v3/parse`
- [x] `GET /api/v3/release`
- [x] `GET /api/v3/rename`
- [x] `GET /ping`

### Sonarr: 24 routes

- [x] `GET /api/v3/calendar/{id}`
- [x] `GET /api/v3/config/downloadclient`
- [x] `GET /api/v3/config/downloadclient/{id}`
- [x] `GET /api/v3/config/host`
- [x] `GET /api/v3/config/host/{id}`
- [x] `GET /api/v3/config/importlist`
- [x] `GET /api/v3/config/importlist/{id}`
- [x] `GET /api/v3/config/indexer`
- [x] `GET /api/v3/config/indexer/{id}`
- [x] `GET /api/v3/config/mediamanagement`
- [x] `GET /api/v3/config/mediamanagement/{id}`
- [x] `GET /api/v3/config/naming`
- [x] `GET /api/v3/config/naming/examples`
- [x] `GET /api/v3/config/naming/{id}`
- [x] `GET /api/v3/config/ui`
- [x] `GET /api/v3/config/ui/{id}`
- [x] `GET /api/v3/indexerflag`
- [x] `GET /api/v3/log`
- [x] `GET /api/v3/manualimport`
- [x] `GET /api/v3/parse`
- [x] `GET /api/v3/release`
- [x] `GET /api/v3/rename`
- [x] `GET /api/v3/series/{id}/folder`
- [x] `GET /ping`
