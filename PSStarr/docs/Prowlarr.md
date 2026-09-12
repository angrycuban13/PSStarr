# Prowlarr API v1

Prowlarr uses API v1. This is an application-specific exception to the Radarr/Sonarr
API v3 baseline, not support for older Radarr/Sonarr APIs.

~~~powershell
Set-PSStarrInstance -Name ProwlarrMain -Application Prowlarr -Url 'http://localhost:9696' -ApiKey '<api-key>'
Get-StarrSystemStatus -Name ProwlarrMain
Get-StarrIndexer -Name ProwlarrMain
~~~

Saved Prowlarr connections automatically select v1 in the shared HTTP transport.
Dedicated Prowlarr wrappers support explicit URL/API-key connections too.
For shared commands with explicit connections, use the transport directly:

~~~powershell
Invoke-StarrApiRequest -Url 'http://localhost:9696' -ApiKey '<api-key>' -ExpectedApplication Prowlarr -Endpoint health
~~~

Shared wrappers given only a URL and API key cannot infer an application from
those values and retain their existing v3 default. The transport's explicit
ApiVersion parameter remains an override. API info and ping remain unversioned.

## Shared named-connection GET reads

- API info, ping, system status, health, backups, commands, tasks, updates.
- Indexers/schema, download clients/schema, notifications/schema.
- Tags/details, custom filters, and structured log pages.
- Host, download-client, and UI settings via Get-StarrApplicationConfiguration.

Only use shared endpoints that Prowlarr actually implements: matching API versions
do not imply Radarr/Sonarr movie, series, quality, or queue resources exist.

## Prowlarr-specific GET reads

Dedicated commands cover application connections/schema, application profiles/schema,
indexer proxies/schema, indexer categories/status/statistics, searches, history
(paged, since, and by indexer), and development configuration.
Use Get-Command -Module PSStarr -Name '*Prowlarr*' to inspect the exported commands.

## Security and scope

Provider credentials identified by privacy metadata or known secret field names
are masked in supported provider reads; redacted output must not be written back
as configuration. Host configuration masks its secret properties too.
Structured logs redact the current connection's API key, but can contain other
sensitive details. Treat API response data as private.

Search GETs can contact indexers and consume quotas. This module does not initiate
downloads through these search commands. XML Newznab/Torznab proxy feeds, torrent/NZB
download endpoints, filesystem browsing, localization, UI routes, and log-file
downloads are outside this JSON GET coverage.

Contracts are checked against the official
[Prowlarr specification](https://raw.githubusercontent.com/Prowlarr/Prowlarr/master/src/Prowlarr.Api.V1/openapi.json).
Unit tests use fake credentials and mocked HTTP; live compatibility is not
established without opt-in integration checks.
