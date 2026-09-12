# Additional GET coverage

This batch implements the 50 application/path pairs from the 2026-09-10 backlog:
26 Radarr and 24 Sonarr. Shared paths count once per application, not once per
PowerShell command. This is route coverage, not a claim of live-server validation.

The baseline contracts were checked against the official
[Radarr master API v3 specification](https://raw.githubusercontent.com/Radarr/Radarr/master/src/Radarr.Api.V3/openapi.json)
and [Sonarr main API v3 specification](https://raw.githubusercontent.com/Sonarr/Sonarr/main/src/Sonarr.Api.V3/openapi.json),
with controllers checked where query behavior required clarification.
Older application releases may lack some routes despite using API v3.

## Application configuration: 30 pairs

Use Get-StarrApplicationConfiguration -Section <section>. Add -ConfigurationId
for the /{id} route. These read the server's settings, not PSStarr's saved connections.

| Section | GET paths under /api/v3/ | Applications | Pairs |
| --- | --- | --- | ---: |
| DownloadClient | config/downloadclient, config/downloadclient/{id} | Both | 4 |
| Host | config/host, config/host/{id} | Both | 4 |
| ImportList | config/importlist, config/importlist/{id} | Both | 4 |
| Indexer | config/indexer, config/indexer/{id} | Both | 4 |
| MediaManagement | config/mediamanagement, config/mediamanagement/{id} | Both | 4 |
| Naming | config/naming, config/naming/{id} | Both | 4 |
| Ui | config/ui, config/ui/{id} | Both | 4 |
| Metadata | config/metadata, config/metadata/{id} | Radarr | 2 |

Host output always masks apiKey, password, passwordConfirmation, sslCertPassword,
and proxyPassword. Do not submit redacted host output as a settings update.
Metadata selects only Radarr among saved instances; explicit URLs remain the
caller's responsibility.

## Shared utilities: 6 pairs

| Command | GET path | Applications |
| --- | --- | --- |
| Get-StarrIndexerFlag | /api/v3/indexerflag | Both |
| Get-StarrLogEntry | /api/v3/log | Both |
| Get-StarrPing | /ping | Both |

Log reads return one page and preserve paging metadata. The transport redacts
the current connection's API key from record text. Arbitrary other secrets in
server logs cannot be reliably identified: treat returned logs as sensitive.
Successful responses are not copied to PSStarr's operational log.
Ping is explicitly unversioned; the usual connection parameters still apply.

## Radarr: 7 pairs

| Command | GET path under /api/v3/ |
| --- | --- |
| Get-StarrRadarrNamingExample | config/naming/examples |
| Get-StarrRadarrImportListMovie | importlist/movie |
| Get-StarrRadarrManualImport | manualimport |
| Get-StarrRadarrMovieFolder | movie/{id}/folder |
| Get-StarrRadarrParse | parse |
| Get-StarrRadarrRelease | release |
| Get-StarrRadarrRenamePreview | rename |

## Sonarr: 7 pairs

| Command | GET path under /api/v3/ |
| --- | --- |
| Get-StarrSonarrCalendarEntry | calendar/{id} |
| Get-StarrSonarrNamingExample | config/naming/examples |
| Get-StarrSonarrManualImport | manualimport |
| Get-StarrSonarrParse | parse |
| Get-StarrSonarrRelease | release |
| Get-StarrSonarrRenamePreview | rename |
| Get-StarrSonarrSeriesFolder | series/{id}/folder |

## Behavior and safety

- No wrapper in this batch sends POST, PUT, PATCH, or DELETE.
- Release GETs can contact indexers, consume quotas, and populate server caches.
  They do not request release downloads.
- Manual-import GETs inspect server files and may be expensive. They do not import.
- Folder GETs compute proposed folder names; they do not browse or move folders.
- Rename GETs preview changes; they do not rename files.
- Naming examples use saved settings unless custom parameters are selected.
  Custom previews require NamingConfigId; omitted custom fields use server
  model defaults, not a merge with saved settings.
- Integration tests remain explicitly opt-in. Unit tests use fake credentials
  and mocked requests; no live servers were contacted for validation.

## Examples

~~~powershell
Get-StarrApplicationConfiguration -Name RadarrMain -Section Naming
Get-StarrLogEntry -Name SonarrMain -Page 1 -PageSize 20 -Level error
Get-StarrRadarrMovieFolder -Name RadarrMain -MovieId 42
Get-StarrSonarrRelease -Name SonarrMain -SeriesId 12 -SeasonNumber 0
~~~
