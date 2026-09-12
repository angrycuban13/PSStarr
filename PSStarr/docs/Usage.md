# Usage

Build the module with ModuleBuilder and import the generated manifest from
`Output/PSStarr/1.0.0/PSStarr.psd1` during development.

## Saved connections

~~~powershell
Set-PSStarrInstance -Name RadarrMain -Application Radarr `
    -Url 'http://localhost:7878' -ApiKey '<api-key>'

Set-PSStarrInstance -Name SonarrMain -Application Sonarr `
    -Url 'http://localhost:8989' -ApiKey '<api-key>'

Get-StarrSystemStatus -Name RadarrMain
Get-StarrHealth -Name SonarrMain
~~~

Windows defaults to DPAPI encryption. Portable AES encryption requires the
caller to provide and retain the AES-256 key; losing that key makes the saved
API key unrecoverable. See `Configuration-Encryption.md` before choosing an
encryption mode.

## Explicit credentials

Explicit credentials are useful in CI and ephemeral sessions because they are
not persisted:

~~~powershell
$status = Get-StarrSystemStatus `
    -Url 'http://localhost:7878' `
    -ApiKey $env:RADARR_API_KEY
~~~

Do not put real API keys in scripts, examples, command history, fixtures, or
logs. Shared wrappers cannot infer that an explicit URL belongs to Prowlarr;
use a saved Prowlarr connection or the documented transport parameters.

## Paging and filters

~~~powershell
$queue = Get-StarrQueue -Name SonarrMain `
    -Page 1 -PageSize 50 -IncludeSeries $true

$missing = Get-StarrRadarrMissing -Name RadarrMain `
    -Page 1 -PageSize 100 -Monitored $true
~~~

Paged commands return the server envelope, including its records and paging
metadata. They do not automatically fetch every page.

## Application reads

~~~powershell
Get-StarrRadarrMovie -Name RadarrMain -TmdbId 550
Get-StarrSonarrSeries -Name SonarrMain -TvdbId 121361
Get-StarrApplicationConfiguration -Name RadarrMain -Section Naming
~~~

Some GET requests have side effects outside PSStarr: release and Prowlarr search
reads can contact indexers and consume quotas, while manual-import reads inspect
server files. These commands do not download or import results.

## State-changing commands

Preview state-changing requests first:

~~~powershell
New-StarrTag -Name RadarrMain -Label reviewed -WhatIf
Set-StarrRadarrMovieTag -Name RadarrMain -MovieId 42 -TagId 3 -ApplyTags Add -WhatIf
~~~

Removing `-WhatIf` authorizes the request. Radarr collection monitoring can
queue a collection refresh and trigger configured collection automation.
