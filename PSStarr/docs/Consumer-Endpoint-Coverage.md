# Consumer Endpoint Coverage

This inventory audits `Just-A-Bunch-Of-Starr-Scripts` at local `main` commit `17b85eb08e37b0c3c0bd72187401080dc7dbb0f7`. It does not inspect the consumer worktree or any other branch.

## Radarr and Sonarr

| Method | Route | Consumer use | PSStarr command |
| --- | --- | --- | --- |
| GET | `/api` | Discover API version | `Get-StarrApiInfo` |
| GET | `/api/v3/tag` | Resolve tags | `Get-StarrTag` |
| GET | `/api/v3/qualityprofile` | Resolve quality profiles | `Get-StarrQualityProfile` |
| GET | `/api/v3/movie` | Read Radarr movies | `Get-StarrRadarrMovie` |
| GET | `/api/v3/series` | Read Sonarr series | `Get-StarrSonarrSeries` |
| GET | `/api/v3/rename?movieId={id}` | Preview Radarr renames | `Get-StarrRadarrRenamePreview` |
| GET | `/api/v3/rename?seriesId={id}` | Preview Sonarr renames | `Get-StarrSonarrRenamePreview` |
| GET | `/api/v3/command/{id}` | Poll a command | `Get-StarrCommand` |
| GET | `/api/v3/collection` | Read Radarr collections | `Get-StarrRadarrCollection` |
| POST | `/api/v3/tag` | Create a tag | `New-StarrTag` |
| POST | `/api/v3/command` | Start searches and renames | `Start-StarrCommand` |
| PUT | `/api/v3/movie/editor` | Add or remove Radarr movie tags | `Set-StarrRadarrMovieTag` |
| PUT | `/api/v3/series/editor` | Add or remove Sonarr series tags | `Set-StarrSonarrSeriesTag` |
| PUT | `/api/v3/collection` | Change Radarr collection monitoring | `Set-StarrRadarrCollectionMonitoring` |

The GET routes were already covered. The write routes are included because Owinenatorr, Upgradinatorr, ZakTag, and Set-RadarrCollectionsMonitored cannot perform their core workflows without them.

## Deliberate exclusions

`Send-ReadarrBooksToKindle` and the Readarr/Lidarr branches in Upgradinatorr are excluded because PSStarr does not support abandoned Readarr or Lidarr applications.

Discord and Notifiarr webhook calls are external notification APIs, not Starr application endpoints, and remain outside PSStarr.
